# -*- coding: utf-8 -*-
class BulkTimeEntriesController < ApplicationController
  unloadable
  layout 'base'
  before_filter :require_login
  before_filter :load_allowed_projects
  before_filter :load_first_project
  before_filter :check_for_no_projects
  before_filter :load_activities
  before_filter :load_deliverables

  helper :custom_fields
  include BulkTimeEntriesHelper

  protect_from_forgery :only => [:index, :save]
  
  def index
    params[:date] ||= today_with_time_zone
    @time_entry = TimeEntry.new(:spent_on => params[:date].to_s)
  end

  def load_assigned_issues
    respond_to do |format|
      format.json {render :json => get_issues(
        params[:project_id]).map{|i| {
          :id => i.id, 
          :subject => i.subject,
          :closed => i.status.is_closed
        }}.sort{|a,b| a[:closed] ? 1 : -1 }}
    end
  end
  
  def save
    if request.post? 
      entries = []
      time_entry = TimeEntry.create_bulk_time_entry(params[:time_entry])

      if params[:date_from].present?
        entries = []
        (params[:date_from]..params[:date_to]).each do |date|
          next unless params[:eligible_days].include?(Date.parse(date).wday.to_s)
          t = time_entry.clone
          t.spent_on = date
          entries += [t]
        end
      else
        entries = [time_entry]
      end

      success = true
      entries.each do |t| 
        if params[:quota_specified] == "true"
          logged = User.current.time_entries.find(:all, :conditions => ['spent_on = ?', t.spent_on]).map(&:hours).sum
          t.hours = [0, User.current.quota - logged].max
        end
        success &&= t.save unless t.hours == 0
      end

      errors = {}
      if success
        message = l(:text_time_added_to_project, 
          :count => entries.map(&:hours).sum, 
          :target => entries.first.project.name)
      else
        errors = entries.first.errors 
        entries = []
      end

      respond_to do |format|
        format.json { render :json => {:entries => entries, :message => message, :errors => errors }}
      end
    end
  end

  def set_hours(time_entry)
    if params[:quota_specified] == "true"
      existing = User.current.time_entries.find(:all, :conditions => ['spent_on = ?', time_entry.spent_on]).map(&:hours).sum
      time_entry.hours = [0, User.current.quota - existing].max
    end
  end
    
  def add_entry
    begin
      spent_on = Date.parse(params[:date])
    rescue ArgumentError
      # Fall through
    end
    spent_on ||= today_with_time_zone
    
    @time_entry = TimeEntry.new(:spent_on => spent_on.to_s)
    respond_to do |format|
      format.js {}
    end
  end
  
  private

  def load_activities
    @activities = TimeEntryActivity.all
  end

  def load_deliverables
    @deliverables = @first_project.ancestor_deliverables.collect{|d| [d.to_s,d.id]}.sort{|a,b| a <=> b}
  end
  
  def load_allowed_projects
    @projects = User.current.projects.find(:all,
      Project.allowed_to_condition(User.current, :log_time))
  end

  def load_first_project
    @first_project = params[:project_id].nil? ?
      @projects.sort_by(&:lft).first :
      Project.find(params[:project_id])
  end

  def check_for_no_projects
    if @projects.empty?
      render :action => 'no_projects'
      return false
    end
  end

  # Returns the today's date using the User's time_zone
  #
  # @return [Date] today
  def today_with_time_zone
    time_proxy = Time.zone = User.current.time_zone
    time_proxy ||= Time # In case the user has no time_zone
    today = time_proxy.now.to_date
  end

  def self.allowed_project?(project_id)
    return User.current.projects.find_by_id(project_id, :conditions => Project.allowed_to_condition(User.current, :log_time))
  end
end
