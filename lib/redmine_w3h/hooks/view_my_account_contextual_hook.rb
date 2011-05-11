class ViewMyAccountContextualHook < Redmine::Hook::ViewListener
  def view_my_account_contextual(context = {})
    link_to 'Time Recording Settings', :controller => 'timesheet', :action => 'settings'
    link_to 'My Profile', :controller => 'users', :action => 'show', :id => User.current
  end
end
