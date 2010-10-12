require 'redmine'
require 'weekdays'
require_dependency 'view_my_account_contextual_hook'

# Patches to the Redmine core.
require 'timesheet_issue_patch'
require 'user_patch'
require 'time_entry_patch'
Dispatcher.to_prepare do
  Issue.send(:include, TimesheetIssuePatch)
  User.send(:include, TimesheetUserPatch)
  TimeEntry.send(:include, TimesheetTimeEntryPatch)
end

unless Redmine::Plugin.registered_plugins.keys.include?(:timesheet_plugin)
  Redmine::Plugin.register :timesheet_plugin do
    name 'Timesheet Plugin'
    author 'Eric Davis of Little Stream Software'
    description 'This is a Timesheet plugin for Redmine to show timelogs for all projects'
    url 'https://projects.littlestreamsoftware.com/projects/redmine-timesheet'
    author_url 'http://www.littlestreamsoftware.com'

    version '0.5.0'
    requires_redmine :version_or_higher => '0.8.0'
    
    settings :default => {'list_size' => '5', 'precision' => '2'}, :partial => 'settings/timesheet_settings'

    permission :see_project_timesheets, { }, :require => :member

    menu(:top_menu,
         :timesheet,
         {:controller => 'timesheet', :action => 'daily'},
         :caption => :timesheet_title,
         :if => Proc.new {
           User.current.allowed_to?(:see_project_timesheets, nil, :global => true) ||
           User.current.allowed_to?(:view_time_entries, nil, :global => true) ||
           User.current.admin?
         })

    menu :project_menu, :time_entries, {:controller => 'timelog', :action => 'new'}, :param => :project_id, :caption => :label_log_time 
  end
end

require 'redmine_goc/hooks/controller_timelog_edit_before_save_hook'

