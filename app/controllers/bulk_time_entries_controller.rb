# -*- coding: utf-8 -*-
class BulkTimeEntriesController < ApplicationController
  unloadable
  layout 'base'
  before_filter :require_login
  before_filter :load_allowed_projects
  before_filter :load_first_project
  before_filter :check_for_no_projects
  before_filter :load_activities
  before_filter :load_time_entry, :only => :index

  helper :custom_fields
  include BulkTimeEntriesHelper

  protect_from_forgery :only => [:index, :save]
  
  def index
  end

  def load_project_data
    deliverables = Project.find(params[:project_id]).ancestor_deliverables.sort{|a,b| a.to_s <=> b.to_s}
    issues = get_issues(params[:project_id])
    issues.sort!{|a,b| a.status.is_closed ? 1 : -1 }
    issues.sort!{|a,b| a.id <=> b.id }


    respond_to do |format|
      format.json {render :json => {
        :issues => issues.map{|i| {
          :id => i.id, 
          :subject => i.subject,
          :closed => i.status.is_closed
        }},
        :deliverables => deliverables.map{|i| {
          :id => i.id,
          :subject => i.to_s
        }}
      }}
    end
  end
  
  def save
    if request.post? 
      time_entry = TimeEntry.new(params[:time_entry])
    elsif request.put?
      time_entry = TimeEntry.find(params[:time_entry][:id])
      time_entry.attributes = params[:time_entry]
    else
      raise
    end

    entries = []

    time_entry.hours = nil if time_entry.hours.blank? or time_entry.hours <= 0
    if self.class.allowed_project?(params[:time_entry][:project_id])
      time_entry.project_id = params[:time_entry][:project_id]
    end
    time_entry.user = User.current

    if params[:date_from].present?
      entries = []
      params[:date_from].to_date.upto(params[:date_to].to_date) do |date|
        next unless params[:eligible_days].include?(date.wday.to_s)
        t = time_entry.clone
        t.spent_on = date
        entries += [t]
      end
    else
      entries = [time_entry]
    end

    success = true
    entries.each do |t| 
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

  private

  def load_time_entry
    params[:date] ||= today_with_time_zone
    if params[:id]
      @time_entry = TimeEntry.find(params[:id])
    else
      @time_entry = TimeEntry.new(:spent_on => params[:date].to_s)
    end
  end

  def load_activities
    @activities = TimeEntryActivity.all
  end

  def load_allowed_projects
    @projects = User.current.projects.find(:all, :conditions =>
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
