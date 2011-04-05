# Budget is a meta class that is used to calculate summary data
# for all the deliverables on a project.  Think of it akin to:
#  has_many :deliverables
#  belongs_to :project
#
class Budget
  
  attr_reader :project
  
  def initialize(deliverables, year)
    @deliverables = deliverables
    @year = year
  end

  # Total budget all of the deliverables
  def budget
    return @deliverables.collect(&:budget).delete_if { |d| d.blank?}.inject { |sum, n| sum + n} || 0.0
  end

  # Total labor budget all of the deliverables
  def labor_budget
    return @deliverables.collect(&:labor_budget).delete_if { |d| d.blank?}.inject { |sum, n| sum + n} || 0.0
  end

  # Amount of the budget spent.  Expressed as as a percentage whole number
  def budget_ratio
    budget = self.budget # cache result
    if budget > 0.0
      return ((self.spent / budget) * 100).round 
    else
      self.progress
    end
  end
  
  # Total amount spent for all the deliverables
  def spent
    @deliverables.collect(&:spent).delete_if { |d| d.blank?}.inject { |sum, n| sum + n } || 0.0
  end

  def invoiced
    @deliverables.collect(&:invoiced).delete_if { |d| d.blank?}.inject { |sum, n| sum + n } || 0.0
  end
  
  # Amount of budget left on the deliverables
  def left
    return self.budget - self.spent
  end

  # Amount of labor budget left on the deliverables
  def labor_budget_left
    return self.labor_budget - self.spent
  end

  def remaining
    return self.budget - self.spent
  end

  # Amount spent over the budget
  def overruns
    if self.left >= 0
      return 0
    else
      return self.left * -1
    end
  end
  
  # Completation progress, expressed as a percentage whole number
  def progress
    return 100 unless @deliverables.size > 0
    return 100 if self.budget == 0.0
    
    balance = 0.0
    
    @deliverables.each do |deliverable|
      balance += deliverable.budget * deliverable.progress
    end
    
    return (balance / self.budget).round
  end
  
  # Budget score.  Will range to 100 (everything done with no money spent) to -100 (nothing done, all the money spent)
  def score
    return self.progress - self.budget_ratio
  end
  
  # Total profit of the deliverables.  This is *not* calculated based on the amount spent and total budget but is the total of the profit amount for the deliverables.
  def profit
    return 0.0 unless @deliverables.size > 0
    
    # Covers fixed and percentage profit though the +profit+ method being overloaded on the Deliverable types
    return @deliverables.collect(&:profit).delete_if { |d| d.blank?}.inject { |sum, n| sum + n } || 0.0
  end
  
  # Dollar amount of time that has been logged to the project itself
  def amount_missing_on_issues
    time_logs = TimeEntry.find_all_by_project_id_and_issue_id(self.project.id, nil)

    return time_logs.collect(&:cost).sum
  end
  
  # Dollar amount of time that has been logged to issues that are not assigned to deliverables
  def amount_missing_on_deliverables
    # Bisect the issues because NOT IN isn't reliable
    all_issues = self.project.issues.find(:all)
    return 0 if all_issues.empty?

    deliverable_issues = self.project.issues.find(:all, :conditions => ["deliverable_id IN (?)", @deliverables.collect(&:id)])

    missing_issues = all_issues - deliverable_issues
    time_logs = missing_issues.collect(&:time_entries).flatten
    
    return time_logs.collect(&:cost).sum
  end
end
