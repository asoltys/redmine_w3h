ActionController::Routing::Routes.draw do |map|
  map.connect 'timesheet/report.:format', :controller => 'timesheet', :action => 'report'
  map.connect 'timelog/calendar', :controller => 'bulk_time_entries', :action => 'calendar'
  map.connect 'issues/:issue_id/time_entry.:format', :controller => 'bulk_time_entries', :action => 'time_entry'
end
