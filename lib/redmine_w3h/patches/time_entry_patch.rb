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
            return cost * (overtime ? 1.5 : 1)
          end

          def regular_hours
            overtime ? 0 : hours
          end

          def overtime_hours
            hours - regular_hours
          end

          def self.create_bulk_time_entry(entry)
            time_entry = TimeEntry.new(entry)
            time_entry.hours = nil if time_entry.hours.blank? or time_entry.hours <= 0
            if BulkTimeEntriesController.allowed_project?(entry[:project_id])
              time_entry.project_id = entry[:project_id] # project_id is protected from mass assignment
            end
            time_entry.user = User.current
            time_entry
          end
        end
      end
    end
  end
end
