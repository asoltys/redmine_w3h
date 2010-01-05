Event.observe(window, 'load', function() {
  $('timesheet-form').hide();

  $('form-toggle').observe('click', function(e) {
    $('timesheet-form').show();
    e.element().hide();
  });
});
