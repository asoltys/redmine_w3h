Event.observe(window, 'load', function() {
  $('date_range').hide();
  $('quota').hide();

  $('show_range').observe('click', function() {
    $('single_date').hide();
    $('date_from').setValue($('time_entry_spent_on').getValue());
    $('time_entry_spent_on').setValue('');
    $('date_range').show();
    $('date_from').focus();
  });

  $('show_single_date').observe('click', function() {
    $('date_range').hide();
    $('single_date').show();
    $('time_entry_spent_on').focus();
    $('time_entry_spent_on').setValue($('date_from').getValue());
    $('date_from').setValue('');
    $('date_to').setValue('');
  });

  $('fill_quota').observe('click', function() {
    $('hours').hide();
    $('time_entry_hours').setValue('');
    $('quota').show();
    $('quota_specified').setValue('true');
  });

  $('specify_hours').observe('click', function() {
    $('quota').hide();
    $('hours').show();
    $('time_entry_hours').focus();
    $('quota_specified').setValue('false');
  });
});
