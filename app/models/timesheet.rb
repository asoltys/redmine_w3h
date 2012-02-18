class Timesheet
  attr_accessor :deliverables, :date_from, :date_to, :projects, :activities, :deliverables, :users, :groups
  attr_accessor :avl_projects, :avl_users, :avl_groups, :avl_activities, :avl_deliverables
  attr_accessor :sel_projects, :sel_users, :sel_groups, :sel_activities, :sel_deliverables
  attr_accessor :period, :period_type
  attr_accessor :time_entries

  WORKING_HOURS = 7.5

  ValidPeriodType = {
    :default => 0,
    :free_period => 1
  }
  
  def initialize(options = { })
    @sel_projects = options[:projects].nil? ? avl_projects : options[:projects].map(&:to_i)
    @projects = Project.find(@sel_projects)

    @sel_activities = options[:activities].nil? ? avl_activities.map(&:id) : options[:activities].map(&:to_i) 
    @activities = Enumeration.find(@sel_activities)
    
    @sel_groups = options[:groups].nil? ? [] : options[:groups].map(&:to_i)
    @groups = Group.find(@sel_groups)

    if @groups.empty?
      @sel_users = options[:users].nil? ? User.current.groups.first.users.map(&:id) : options[:users].map(&:to_i)
    else
      @sel_users = groups.map(&:users).flatten.map(&:id)
    end
    @users = User.find(@sel_users)

    @sel_deliverables = options[:deliverables].nil? ? avl_deliverables.map(&:id) : options[:deliverables].map(&:to_i).map{|i| i == 0 ? nil : i}
    @deliverables = []
    real_deliverables = @sel_deliverables.reject{|id| id.nil?}
    @deliverables = Deliverable.find(real_deliverables) unless real_deliverables.empty?
    @deliverables.push(fake_deliverable) if sel_deliverables.include? nil

    @date_from = options[:date_from] || Date.today.to_s
    @date_to = options[:date_to] || Date.today.to_s

    @period_type = options[:period_type].nil? ? Timesheet::ValidPeriodType[:free_period] : options[:period_type].to_i
    self.period = options[:period]

    @time_entries = TimeEntry.find(
      :all,
      :conditions => conditions,
      :include => [:activity, :user, :project, {:issue => [:tracker, :assigned_to, :priority]}],
      :order => "spent_on ASC")
  end

  def avl_projects
    if User.current.admin?
      return Project.find(:all, :order => 'name ASC')
    else
      return User.current.projects.find(:all, :order => 'name ASC')
    end
  end

  def avl_activities
    TimeEntryActivity.shared.active
  end

  def avl_users
    User.find(:all).sort { |a,b| a.to_s.downcase <=> b.to_s.downcase }
  end

  def avl_groups
    Group.find(:all).sort { |a,b| a.to_s.downcase <=> b.to_s.downcase }
  end    

  def avl_deliverables
    deliverables = Deliverable.all.sort { |a,b| a.to_s <=> b.to_s }
    deliverables.push(fake_deliverable)
    deliverables.reverse
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

  def conditions
    conditions = [
      "#{TimeEntry.table_name}.project_id IN (:projects)" +
      " AND #{TimeEntry.table_name}.user_id IN (:users) " +
      " AND #{TimeEntry.table_name}.activity_id IN (:activities)",
      {
        :projects => sel_projects,
        :activities => sel_activities,
        :users => sel_users
      }]

    if date_from && date_to
      conditions[0] += " AND #{TimeEntry.table_name}.spent_on BETWEEN :from AND :to"
      conditions[1][:from] = date_from
      conditions[1][:to] = date_to
    end

    unless deliverables.empty?
      conditions[0] += " AND (#{TimeEntry.table_name}.deliverable_id IN (:deliverables)"
      if sel_deliverables.include? nil
        conditions[0] += " OR #{TimeEntry.table_name}.deliverable_id IS NULL)" 
      else
        conditions[0] += ")"
      end
      conditions[1][:deliverables] = sel_deliverables
    end

    return conditions
  end

  def period=(period)
    return if @period_type == Timesheet::ValidPeriodType[:free_period]
    fiscal_year = Date.today.month < 4 ? Date.today.year - 1 : Date.today.year

    case period.to_s
    when 'today'
      @date_from = @date_to = Date.today
    when '30_days'
      @date_from = Date.today - 30
      @date_to = Date.today
    when 'fiscal_year'
      @date_from = Date.civil(fiscal_year, 4, 1)
      @date_to = Date.civil(fiscal_year + 1, 3, 31)
    when 'q1'
      @date_from = Date.civil(fiscal_year, 4, 1)
      @date_to = Date.civil(fiscal_year, 6, 30)
    when 'q2'
      @date_from = Date.civil(fiscal_year, 7, 1)
      @date_to = Date.civil(fiscal_year, 9, 30)
    when 'q3'
      @date_from = Date.civil(fiscal_year, 10, 1)
      @date_to = Date.civil(fiscal_year, 12, 31)
    when 'q4'
      @date_from = Date.civil(fiscal_year + 1, 1, 1)
      @date_to = Date.civil(fiscal_year + 1, 3, 31)
    when 'all'
      @date_from = @date_to = nil
    end
  end
end
