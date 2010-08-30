require_dependency 'time_entry'

module TimesheetTimeEntryPatch
  def self.included(base) # :nodoc:
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      named_scope :by_user, lambda { |user_id| { :conditions => ["user_id = ?", user_id]}}

      def value
        return (hours/7.5) * 445
      end
    end
  end
end
