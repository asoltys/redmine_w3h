class ViewMyAccountContextualHook < Redmine::Hook::ViewListener
  def view_my_account_contextual(context = {})
    l = " | "
    l <<  link_to(l(:time_recording_settings), :controller => 'timesheet', :action => 'settings')
    l << " | "
    l << link_to(l(:my_profile), :controller => 'users', :action => 'show', :id => User.current)
  end
end
