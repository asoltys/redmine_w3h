# A Deliverable is an item that is created as part of the project.  These items
# contain a collection of issues.
class Deliverable < ActiveRecord::Base
  unloadable
  validates_presence_of :subject
  
  belongs_to :project
  has_many :issues, :dependent => :nullify
  has_many :time_entries, :dependent => :nullify

  acts_as_attachable :view_permission => :view_budget, :delete_permission => :manage_budget
  acts_as_customizable

  named_scope :current, :conditions => ["due BETWEEN '#{Date.today - 4.months}' AND '#{(Date.today - 4.months) + 1.year}-03-31'"]

  def timelogs
    TimeEntry.find(:all, :conditions => {:deliverable_id => self.id}) 
  end 
  
  def spent
    self.timelogs.collect(&:value).sum 
  end

  def budget_remaining
    return self.budget - self.spent
  end
  alias :left :budget_remaining
  
  def hours_used
    return 0 unless self.issues.size > 0
    return self.issues.collect(&:time_entries).flatten.collect(&:hours).sum
  end
  
  def editable_by?(user)
    (user == user && user.allowed_to?(:manage_budget, project))
  end

  def to_s(include_fiscal_year = true)
    s = ""
    s = "#{fiscal_year.to_s}/#{(fiscal_year+1).to_s}: " if include_fiscal_year
    s += self.project.name + ' - ' + self.subject
  end

  def fiscal_year
    return Date.today.year if due.nil?
    (due - 3.months).year
  end
end
