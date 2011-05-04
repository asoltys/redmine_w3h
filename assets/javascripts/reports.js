Event.observe(window, 'load', function() { 
  $('toggle-form').observe('click', function(e) {
    var link = e.element().select('a').first();
    $('timesheet-form').toggle();
  });

  $('timesheet_groups_').observe('change', function() {
    if ($('timesheet_groups_').getValue().size() == 0) {
      $('timesheet_users_').enable();
    } else {
      $$('#timesheet_users_ option').each(function(e) {e.selected = false;});
      $('timesheet_users_').disable();
    }
  });
});
