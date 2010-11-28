module RedmineW3H
  module Patches
    module TimeEntryPatch 
      def self.included(base) # :nodoc:
        # Same as typing in the class 
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development
          belongs_to :deliverable
          named_scope :by_user, lambda { |user_id| { :conditions => ["user_id = ?", user_id]}}

          def billable_hours
            deliverable.nil? ? 0 : hours
          end

          def non_billable_hours
            hours - billable_hours
          end

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
  end
end
