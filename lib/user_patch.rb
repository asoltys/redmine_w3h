require_dependency 'user'

module TimesheetUserPatch
  def self.included(base) # :nodoc:
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      named_scope :active, :conditions => ['status = ?', User::STATUS_ACTIVE]
      named_scope :time_recorders, :conditions => "users.id IN (SELECT DISTINCT user_id FROM time_entries)"
      has_many :time_entries, :dependent => :delete_all
    end
  end
end


