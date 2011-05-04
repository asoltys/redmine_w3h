class Timesheet
  attr_accessor :deliverables, :date_from, :date_to, :projects, :activities, :deliverables, :users, :groups
  attr_accessor :available_projects, :available_users, :available_groups, :available_activities, :available_deliverables
  attr_accessor :selected_projects, :selected_users, :selected_groups, :selected_activities, :selected_deliverables
  attr_accessor :period, :period_type
  attr_accessor :time_entries

  WORKING_HOURS = 7.5

  ValidPeriodType = {
    :default => 0,
    :free_period => 1
  }
  
  def initialize(options = { })
    @selected_projects = options[:projects].nil? ? available_projects : options[:projects].map(&:to_i)
    @projects = Project.find(@selected_projects)

    @selected_activities = options[:activities].nil? ? available_activities.map(&:id) : options[:activities].map(&:to_i) 
    @activities = Enumeration.find(@selected_activities)
    
    @selected_groups = options[:groups].nil? ? [] : options[:groups].map(&:to_i)
    @groups = Group.find(@selected_groups)

    if groups.empty?
      @selected_users = options[:users].nil? ? User.current.groups.first.users.map(&:id) : options[:users].map(&:to_i)
    else
      @selected_users = groups.map(&:users).flatten.map(&:id)
    end
    @users = User.find(@selected_users)

    unless options[:deliverables].nil?
      @selected_deliverables = options[:deliverables].map(&:to_i).map{|i| i == 0 ? nil : i}
    else
      @selected_deliverables = available_deliverables.map(&:id)
    end
    @deliverables = []
    real_deliverables = @selected_deliverables.reject{|id| id.nil?}
    @deliverables = Deliverable.find(real_deliverables) unless real_deliverables.empty?
    @deliverables.push(fake_deliverable) if selected_deliverables.include? nil

    @date_from = options[:date_from] || Date.today.to_s
    @date_to = options[:date_to] || Date.today.to_s

    if options[:period_type]
      @period_type = options[:period_type].to_i
    else
      @period_type = Timesheet::ValidPeriodType[:free_period]
    end
    @period = options[:period] || nil

    @time_entries = TimeEntry.find(
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
    TimeEntryActivity.shared.active
  end

  def available_users
    User.find(:all).sort { |a,b| a.to_s.downcase <=> b.to_s.downcase }
  end

  def available_groups
    Group.find(:all).sort { |a,b| a.to_s.downcase <=> b.to_s.downcase }
  end    

  def available_deliverables
    deliverables = Deliverable.all.sort { |a,b| a.to_s <=> b.to_s }
    deliverables.push(fake_deliverable)
  end
  
  def fake_deliverable
    d = "Non-Billable Time"
    class <<d
      def id; nil; end; 
      def to_s; self; end;
      def budget; 0; end;
    end
    return d
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
    if self.date_to.is_a?(String)
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
        :projects => selected_projects,
        :activities => selected_activities,
        :users => selected_users
      }]

    if date_from && date_to
      conditions[0] += " AND #{TimeEntry.table_name}.spent_on BETWEEN :from AND :to"
      conditions[1][:from] = date_from
      conditions[1][:to] = date_to
    end

    unless deliverables.empty?
      conditions[0] += " AND (#{TimeEntry.table_name}.deliverable_id IN (:deliverables)"
      if selected_deliverables.include? nil
        conditions[0] += " OR #{TimeEntry.table_name}.deliverable_id IS NULL)" 
      else
        conditions[0] += ")"
      end
      conditions[1][:deliverables] = selected_deliverables
    end

    return conditions
  end

  def period=(period)
    return if self.period_type == Timesheet::ValidPeriodType[:free_period]
    fiscal_year = Date.today.month < 4 ? Date.today.year - 1 : Date.today.year

    case period.to_s
    when 'today'
      self.date_from = self.date_to = Date.today
    when '30_days'
      self.date_from = Date.today - 30
      self.date_to = Date.today
    when 'fiscal_year'
      self.date_from = Date.civil(fiscal_year, 4, 1)
      self.date_to = Date.civil(fiscal_year + 1, 3, 31)
    when 'q1'
      self.date_from = Date.civil(fiscal_year, 4, 1)
      self.date_to = Date.civil(fiscal_year, 6, 30)
    when 'q2'
      self.date_from = Date.civil(fiscal_year, 7, 1)
      self.date_to = Date.civil(fiscal_year, 9, 30)
    when 'q3'
      self.date_from = Date.civil(fiscal_year, 10, 1)
      self.date_to = Date.civil(fiscal_year, 12, 31)
    when 'q4'
      self.date_from = Date.civil(fiscal_year + 1, 1, 1)
      self.date_to = Date.civil(fiscal_year + 1, 3, 31)
    when 'all'
      self.date_from = self.date_to = nil
    end

    return self
  end
end
