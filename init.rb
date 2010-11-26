require 'redmine'

unless Redmine::Plugin.registered_plugins.keys.include?(:redmine_w3h)
  Redmine::Plugin.register :redmine_w3h do
    name 'W3H (Who, What, When and How Much?)'
    author 'Adam Soltys, Public Works and Government Services Canada'
    description 'This plugin adds budget and time management functionality to Redmine'
    url 'https://github.com/asoltys/redmine_w3h'
    author_url 'http://adamsoltys.com/'

    version '0.0.1'
    requires_redmine :version_or_higher => '1.0.1'
    
    settings :default => {'list_size' => '10', 'precision' => '2'}
    permission :see_project_timesheets, { }, :require => :member

    menu(
      :top_menu,
      :timesheet,
      {:controller => 'timesheet', :action => 'daily'},
      :caption => :timesheet_title,
      :if => Proc.new {
        User.current.allowed_to?(:see_project_timesheets, nil, :global => true) ||
        User.current.allowed_to?(:view_time_entries, nil, :global => true) ||
        User.current.admin? 
      }
    )

    menu( 
      :project_menu, 
      :time_entries, 
      {:controller => 'timelog', :action => 'new'}, 
      :param => :project_id, 
      :caption => :label_log_time
    )
  end
end

require 'dispatcher'
Dispatcher.to_prepare :redmine_w3h do
  gem 'weekdays', :version => '1.0'
  require_dependency 'weekdays'

  require_dependency 'issue'
  Issue.send(:include, W3H::Patches::IssuePatch)

  require_dependency 'project'
  Project.send(:include, W3H::Patches::ProjectPatch)

  require_dependency 'query'
  Query.send(:include, W3H::Patches::QueryPatch)

  require_dependency 'time_entry'
  TimeEntry.send(:include, W3H::Patches::TimeEntryPatch)

  require_dependency 'user'
  User.send(:include, W3H::Patches::UserPatch)
end

require 'redmine_w3h/hooks/budget_issue_hook'
require 'redmine_w3h/hooks/budget_project_hook'
require 'redmine_w3h/hooks/controller_timelog_edit_before_save_hook'
require 'redmine_w3h/hooks/view_my_account_contextual_hook'
