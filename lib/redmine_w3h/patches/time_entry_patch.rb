module RedmineGOC
  module Patches
    module TimeEntryPatch 
      def self.included(base) # :nodoc:
        # Same as typing in the class 
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development
          belongs_to :deliverable

          def billable_hours
            deliverable.nil? ? 0 : hours
          end

          def non_billable_hours
            hours - billable_hours
          end
        end
      end
    end
  end
end
