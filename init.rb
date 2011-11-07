require 'redmine'

unless Redmine::Plugin.registered_plugins.keys.include?(:redmine_w3h)
  Redmine::Plugin.register :redmine_w3h do
    name 'W3H (Who, What, When and How Much?)'
    author 'Adam Soltys, Public Works and Government Services Canada'
    description 'This plugin adds additional budget and time management functionality to Redmine'
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
      :top_menu, 
      :bulk_time_entry, 
      { :controller => "bulk_time_entries", :action => 'index' }, 
      :caption => :bulk_time_entry_title, 
      :if => Proc.new {
        User.current.allowed_to?(:log_time, nil, :global => true)
      } 
    )

    menu( 
      :project_menu, 
      :time_entries, 
      {:controller => 'timelog', :action => 'new'}, 
      :param => :project_id, 
      :caption => :label_log_time
    )


    menu(
      :project_menu, 
      :budget, 
      {:controller => "deliverables", :action => 'index'},
      :caption => :budget_title
    )

    project_module :budget_module do
      permission :view_budget, { :deliverables => [:index, :issues]}
      permission :manage_budget, { :deliverables => [:new, :edit, :create, :update, :destroy, :preview, :bulk_assign_issues]}
    end
  end
end

require 'dispatcher'
Dispatcher.to_prepare :redmine_w3h do
  require_dependency 'weekdays'

  require_dependency 'context_menus_controller'
  require 'redmine_w3h/patches/context_menus_controller_patch'
  ContextMenusController.send(:include, RedmineW3H::Patches::ContextMenusControllerPatch)

  require_dependency 'issue'
  require 'redmine_w3h/patches/issue_patch'
  Issue.send(:include, RedmineW3H::Patches::IssuePatch)

  require_dependency 'project'
  require 'redmine_w3h/patches/project_patch'
  Project.send(:include, RedmineW3H::Patches::ProjectPatch)

  require_dependency 'query'
  require 'redmine_w3h/patches/query_patch'
  Query.send(:include, RedmineW3H::Patches::QueryPatch)

  require_dependency 'time_entry'
  require 'redmine_w3h/patches/time_entry_patch'
  TimeEntry.send(:include, RedmineW3H::Patches::TimeEntryPatch)

  require_dependency 'timelog_controller'
  require 'redmine_w3h/patches/timelog_controller_patch'
  TimelogController.send(:include, RedmineW3H::Patches::TimelogControllerPatch)

  require_dependency 'user'
  require 'redmine_w3h/patches/user_patch'
  User.send(:include, RedmineW3H::Patches::UserPatch)
end

require 'redmine_w3h/hooks/budget_issue_hook'
require 'redmine_w3h/hooks/budget_project_hook'
require 'redmine_w3h/hooks/controller_timelog_edit_before_save_hook'
require 'redmine_w3h/hooks/view_my_account_contextual_hook'
