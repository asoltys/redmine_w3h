# -*- coding: utf-8 -*-
class BulkTimeEntriesController < ApplicationController
  unloadable
  layout 'base'
  before_filter :require_login
  before_filter :load_activities
  before_filter :load_allowed_projects
  before_filter :load_first_project
  before_filter :check_for_no_projects

  helper :custom_fields
  include BulkTimeEntriesHelper

  protect_from_forgery :only => [:index, :save]
  
  def index
    params[:date] ||= today_with_time_zone
    @time_entries = [TimeEntry.new(:spent_on => params[:date].to_s)]
  end

  def load_assigned_issues
    @issues = get_issues(params[:project_id])
    @selected_project = BulkTimeEntriesController.allowed_project?(params[:project_id])
    respond_to do |format|
      format.js {}
    end
  end
  
  def save
    if request.post? 
      entries = {}
      messages = {}
      errors = {}

      params[:time_entries].each_pair do |html_id, fields|
        non_attributes = ["date_from", "date_to", "quota_specified"]
        attributes = fields.reject{|k,v| non_attributes.include? k}
        time_entry = TimeEntry.create_bulk_time_entry(attributes)
        success = true
        collective_hours = 0

        if fields[:date_from].present?
          (fields[:date_from]..fields[:date_to]).each do |date|
            t = time_entry.clone
            t.spent_on = date
            set_hours(t) if fields[:quota_specified] == "true"
            collective_hours += t.hours
            success &&= t.save unless t.hours == 0
            if success
              entries[html_id] ||= [t] 
              entries[html_id] += [t]
            end
          end
          time_entry.hours = collective_hours
        else
          set_hours(time_entry) if fields[:quota_specified] == "true"
          success = time_entry.save
          entries[html_id] = [time_entry] if success
        end

        if success
          messages[html_id] = l(:text_time_added_to_project, 
            :count => time_entry.hours, 
            :target => time_entry.project.name)
        else
          errors[html_id] = time_entry.errors 
        end
      end

      request.format = :json
      respond_to do |format|
        format.json { render :json => {:entries => entries, :messages => messages, :errors => errors }}
      end
    end
  end

  def set_hours(time_entry)
    existing = User.current.time_entries.find(:all, :conditions => ['spent_on = ?', time_entry.spent_on]).map(&:hours).sum
    time_entry.hours = [0, User.current.quota - existing].max
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
  
  def load_allowed_projects
    @projects = User.current.projects.find(:all,
      Project.allowed_to_condition(User.current, :log_time))
  end

  def load_first_project
    @first_project = @projects.sort_by(&:lft).first unless @projects.empty?
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
