module RedmineW3H
  module Patches
    module ContextMenusControllerPatch 
      def self.included(base) # :nodoc:
        # Same as typing in the class 
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development
          def time_entries
            @time_entries = TimeEntry.all(
               :conditions => {:id => params[:ids]}, :include => :project)
            @projects = @time_entries.collect(&:project).compact.uniq
            @project = @projects.first if @projects.size == 1
            @activities = TimeEntryActivity.shared.active
            @can = {:edit   => User.current.allowed_to?(:log_time, @projects),
                    :update => User.current.allowed_to?(:log_time, @projects),
                    :delete => User.current.allowed_to?(:log_time, @projects)
                    }
            @back = back_url
            render :layout => false
          end
        end
      end
    end
  end
end
