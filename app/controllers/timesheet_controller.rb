class TimesheetController < ApplicationController
  unloadable

  layout 'base'
  before_filter :get_user, :only => :daily
  before_filter :get_timesheet, :except => :agreements

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

    if @timesheet.avl_projects.empty?
      render :action => 'no_projects'
      return
    end
  end

  def get_timesheet
    unless params[:timesheet]
      params[:timesheet] = {} 
      params[:timesheet][:users] = User.current.groups.length > 0 ? User.current.groups.first.users.map(&:id) : [User.current.id]
      params[:timesheet][:period_type] = Timesheet::ValidPeriodType[:free_period]
      params[:timesheet][:date_from] = 9.weekdays_ago.strftime('%Y-%m-%d')
      params[:timesheet][:date_to] = Date.today

      params[:timesheet][:users] = [params[:user_id]] unless params[:user_id].nil?
      params[:timesheet][:deliverables] = [params[:deliverable_id]] unless params[:deliverable_id].nil?
    end

    @timesheet = Timesheet.new(params[:timesheet])
  end

  def daily
    if @timesheet.avl_projects.empty?
      render :action => 'no_projects'
      return
    end

    respond_to do |format|
      format.html { render :action => 'daily' }
    end
  end

  def report
    if @timesheet.avl_projects.empty?
      render :action => 'no_projects'
      return
    end

    respond_to do |format|
      format.html { render :action => 'report' }
    end
  end

  def agreements
    unless params[:timesheet]
      params[:timesheet] = {} 
      params[:timesheet][:period_type] = Timesheet::ValidPeriodType[:free_period]
      params[:timesheet][:date_from] = 9.weekdays_ago.strftime('%Y-%m-%d')
      params[:timesheet][:date_to] = Date.today
      params[:timesheet][:users] = User.find(:all).map(&:id)

      params[:timesheet][:users] = [params[:user_id]] unless params[:user_id].nil?
      params[:timesheet][:deliverables] = [params[:deliverable_id]] unless params[:deliverable_id].nil?
    end

    @timesheet = Timesheet.new(params[:timesheet])
  end
  alias_method :projects, :agreements

  private
  def get_user
    params[:user_id] = User.current.id unless params[:user_id]
  end
end
