require_dependency 'time_entry'

module TimesheetTimeEntryPatch
  def self.included(base) # :nodoc:
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      named_scope :by_user, lambda { |user_id| { :conditions => ["user_id = ?", user_id]}}
      attr_accessor :user_id

      def value
        return (hours / 7.5) * (overtime ? 810 : 445)
      end

      def regular_hours
        overtime ? 0 : hours
      end

      def overtime_hours
        hours - regular_hours
      end
    end
  end
end
