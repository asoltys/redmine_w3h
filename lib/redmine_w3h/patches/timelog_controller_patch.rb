module RedmineW3H
  module Patches
    module TimelogControllerPatch 
      def self.included(base) # :nodoc:
        # Same as typing in the class 
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development

          def new
            redirect_to '/bulk_time_entries', 
              :project_id => params[:project_id], 
              :issue_id => params[:issue_id]
          end

          def edit
            redirect_to '/bulk_time_entries', 
              :time_entry_id => params[:time_entry_id]
          end
        end
      end
    end
  end
end
