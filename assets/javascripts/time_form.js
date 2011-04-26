Event.observe(window, 'load', function() {
  $('date_range').hide();
  $('show_range').observe('click', function() {
    $('single_date').hide();
    $('date_from').setValue($('time_entry_spent_on').getValue());
    $('time_entry_spent_on').setValue('');
    $('date_range').show();
  });

  $('show_single_date').observe('click', function() {
    $('date_range').hide();
    $('single_date').show();
    $('time_entry_spent_on').setValue($('date_from').getValue());
    $('date_from').setValue('');
    $('date_to').setValue('');
  });
});
