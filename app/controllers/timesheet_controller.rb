class TimesheetController < ApplicationController
  unloadable

  layout 'base'
  before_filter :get_list_size
  before_filter :get_precision
  before_filter :get_activities

  helper :sort
  include SortHelper
  helper :issues
  include ApplicationHelper
  helper :timelog

  def index
    unless @timesheet
      @timesheet ||= Timesheet.new
      @timesheet.users = [] # Clear users so they aren't selected
    end

    if @timesheet.available_projects.empty?
      render :action => 'no_projects'
      return
    end
  end

  def mytimesheet
    timesheet = {} 
    timesheet[:users] = [User.current.id]
    timesheet[:period_type] = Timesheet::ValidPeriodType[:free_period]
    timesheet[:date_from] = 4.weekdays_ago.strftime('%Y-%m-%d')
    timesheet[:date_to] = Date.today
    redirect_to :action => 'report', :params => {:timesheet => timesheet}
  end

  def report
    unless params[:deliverable_id].nil?
      params[:timesheet] = {}
      params[:timesheet][:deliverables] = [params[:deliverable_id]] 
    end

    if params && params[:timesheet]
      @timesheet = Timesheet.new( params[:timesheet] )
    else
      redirect_to :action => 'index'
      return
    end

    if @timesheet.available_projects.empty?
      render :action => 'no_projects'
      return
    end

    respond_to do |format|
      format.html { render :action => 'report' }
    end
  end

  def delinquency
    timesheet = {}
    timesheet[:date_from] = 60.weekdays_ago.strftime('%Y-%m-%d')
    timesheet[:date_to] = Date.today
    @timesheet = Timesheet.new(timesheet)

    respond_to do |format|
      format.html { render :action => 'delinquency' }
    end
  end

  def settings
    @user = User.current
    if request.post?
      @user.quota = params[:user][:quota]
      if @user.save
        flash[:notice] = l(:notice_account_updated)
      end
    end
  end

  def context_menu
    @time_entries = TimeEntry.find(:all, :conditions => ['id IN (?)', params[:ids]])
    render :layout => false
  end

  private
  def get_list_size
    @list_size = Setting.plugin_timesheet_plugin['list_size'].to_i
  end

  def get_precision
    precision = Setting.plugin_timesheet_plugin['precision']
    
    if precision.blank?
      # Set precision to a high number
      @precision = 10
    else
      @precision = precision.to_i
    end
  end

  def get_activities
    @activities = TimesheetCompatibility::Enumeration::activities
  end
end
