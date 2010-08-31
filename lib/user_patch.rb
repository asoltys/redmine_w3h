require_dependency 'user'

module TimesheetUserPatch
  def self.included(base) # :nodoc:
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      named_scope :active, :conditions => ['status = ?', User::STATUS_ACTIVE]
      named_scope :time_recorders, :conditions => "users.id IN (SELECT DISTINCT user_id FROM time_entries)"
      has_many :time_entries, :dependent => :delete_all

      def logged_time(day)
        entries = TimeEntry.find(:all, :conditions => ["time_entries.user_id = ? AND time_entries.spent_on = ?", id, day])
        return entries.map{|e| e.hours}.sum
      end

      def logged_time_class(day)
        return 'delinquent' if day.past? && logged_time(day) < Timesheet::WORKING_HOURS
        return 'overtime' if logged_time(day) >= Timesheet::WORKING_HOURS 
      end
    end
  end
end


