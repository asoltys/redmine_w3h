module RedmineW3H
  module Patches
    module TimelogControllerPatch 
      def self.included(base) # :nodoc:
        # Same as typing in the class 
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development

          def new
            redirect_to :controller => :bulk_time_entries
          end

          def edit
            redirect_to :controller => :bulk_time_entries, :id => params[:id]
          end
        end
      end
    end
  end
end
