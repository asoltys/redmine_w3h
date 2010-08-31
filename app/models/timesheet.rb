class Timesheet
  attr_accessor :deliverables, :date_from, :date_to, :projects, :activities, :deliverables, :users
  attr_accessor :available_projects, :available_users, :available_activities, :available_deliverables
  attr_accessor :selected_projects, :selected_users, :selected_activities, :selected_deliverables
  attr_accessor :period, :period_type
  attr_accessor :time_entries

  WORKING_HOURS = 7.5

  ValidPeriodType = {
    :default => 0,
    :free_period => 1
  }
  
  def initialize(options = { })
    unless options[:projects].nil?
      self.selected_projects = options[:projects].map(&:to_i)
    else
      self.selected_projects = available_projects.map(&:id)
    end
    self.projects = Project.find(self.selected_projects)

    unless options[:activities].nil?
      self.selected_activities = options[:activities].map(&:to_i)
    else
      self.selected_activities = available_activities.map(&:id)
    end
    self.activities = Enumeration.find(self.selected_activities)
    
    unless options[:users].nil?
      self.selected_users = options[:users].map(&:to_i)
    else
      self.selected_users = available_users.map(&:id)
    end
    self.users = User.find(self.selected_users)

    unless options[:deliverables].nil?
      self.selected_deliverables = options[:deliverables].map(&:to_i)
    else
      self.selected_deliverables = []
    end
    self.deliverables = Deliverable.find(self.selected_deliverables)

    self.date_from = options[:date_from] || Date.today.to_s
    self.date_to = options[:date_to] || Date.today.to_s

    if options[:period_type]
      self.period_type = options[:period_type].to_i
    else
      self.period_type = Timesheet::ValidPeriodType[:free_period]
    end
    self.period = options[:period] || nil

    self.time_entries = TimeEntry.find(
      :all,
      :conditions => conditions,
      :include => [:activity, :user, :project, {:issue => [:tracker, :assigned_to, :priority]}],
      :order => "spent_on ASC")
  end

  def available_projects
    if User.current.admin?
      return Project.find(:all, :order => 'name ASC')
    else
      return User.current.projects.find(:all, :order => 'name ASC')
    end
  end

  def available_activities
    TimesheetCompatibility::Enumeration::activities
  end

  def available_users
    User.active.time_recorders.sort { |a,b| a.to_s.downcase <=> b.to_s.downcase }
  end

  def available_deliverables
    Deliverable.current.sort { |a,b| a.to_s <=> b.to_s }
  end

  def required
    return quota * users.length unless quota.nil?
  end

  def total 
    time_entries.map(&:hours).sum
  end

  def billed
    self.time_entries.map(&:billable_hours).sum
  end

  def unbilled
    total - billed
  end

  private

  def quota
    if self.date_from.is_a?(String)
      self.date_from = Date.parse(self.date_from)
      self.date_to = Date.parse(self.date_to)
    end

    unless self.date_from.nil?
      return (self.date_from.weekdays_until(self.date_to) + (self.date_to.weekday? ? 1 : 0)) * WORKING_HOURS
    end
  end

  def conditions
    conditions = [
      "#{TimeEntry.table_name}.project_id IN (:projects)" +
      " AND #{TimeEntry.table_name}.user_id IN (:users) " +
      " AND #{TimeEntry.table_name}.activity_id IN (:activities)",
      {
        :projects => self.selected_projects,
        :activities => self.selected_activities,
        :users => self.selected_users
      }]

    if self.date_from && self.date_to
      conditions[0] += " AND #{TimeEntry.table_name}.spent_on BETWEEN :from AND :to"
      conditions[1][:from] = self.date_from
      conditions[1][:to] = self.date_to
    end

    unless self.deliverables.empty?
      conditions[0] += " AND #{TimeEntry.table_name}.deliverable_id IN (:deliverables)"
      conditions[1][:deliverables] = self.selected_deliverables
    end

    return conditions
  end

  def period=(period)
    return if self.period_type == Timesheet::ValidPeriodType[:free_period]

    case period.to_s
    when 'today'
      self.date_from = self.date_to = Date.today
    when 'yesterday'
      self.date_from = self.date_to = Date.today - 1
    when 'current_week' # Mon -> Sun
      self.date_from = Date.today - (Date.today.cwday - 1)%7
      self.date_to = self.date_from + 6
    when 'last_week'
      self.date_from = Date.today - 7 - (Date.today.cwday - 1)%7
      self.date_to = self.date_from + 6
    when '7_days'
      self.date_from = Date.today - 7
      self.date_to = Date.today
    when 'current_month'
      self.date_from = Date.civil(Date.today.year, Date.today.month, 1)
      self.date_to = (self.date_from >> 1) - 1
    when 'last_month'
      self.date_from = Date.civil(Date.today.year, Date.today.month, 1) << 1
      self.date_to = (self.date_from >> 1) - 1
    when '30_days'
      self.date_from = Date.today - 30
      self.date_to = Date.today
    when 'current_year'
      self.date_from = Date.civil(Date.today.year, 1, 1)
      self.date_to = Date.civil(Date.today.year, 12, 31)
    when 'all'
      self.date_from = self.date_to = nil
    end

    return self
  end
end
