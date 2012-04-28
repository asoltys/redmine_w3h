ActionController::Routing::Routes.draw do |map|
  map.connect 'timesheet/report.:format', :controller => 'timesheet', :action => 'report'
  map.connect 'timelog/calendar', :controller => 'bulk_time_entries', :action => 'calendar'
end
