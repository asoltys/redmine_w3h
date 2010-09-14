Event.observe(window, 'load', function() { 
  $('toggle-form').observe('click', function(e) {
    var link = e.element().select('a').first();
    $('timesheet-form').toggle();
  });
});
