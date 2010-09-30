module RedmineGoc
  module Hooks
    class ControllerTimelogEditBeforeSaveHook < Redmine::Hook::ViewListener
      def controller_timelog_edit_before_save(context = {})
        if context[:params][:time_entry]
          context[:time_entry].user = User.find(context[:params][:time_entry][:user_id])
        end

        unless context[:time_entry].issue.nil? || context[:params][:time_entry]
          context[:time_entry].deliverable = context[:time_entry].issue.deliverable
        end
      end
    end
  end
end
