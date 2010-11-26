# A Deliverable is an item that is created as part of the project.  These items
# contain a collection of issues.
class Deliverable < ActiveRecord::Base
  unloadable
  validates_presence_of :subject
  
  belongs_to :project
  has_many :issues, :dependent => :nullify
  has_many :time_entries, :dependent => :nullify

  acts_as_attachable :view_permission => :view_budget, :delete_permission => :manage_budget

  named_scope :current, :conditions => ["due BETWEEN '2010-04-01' AND '2011-03-31'"]

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

  def to_s
    self.due.year.to_s  + ": " + self.project.name + ' - ' + self.subject
  end
end
