jQuery.noConflict();
(function($) { 
  $(function() {
    $('.show_range').click(function() {
      $('.single_date').hide();
      $('.date_from').val($('.time_entry_spent_on').val());
      $('.time_entry_spent_on').val('');
      $('.date_range').show();
      $('.date_from').focus();
    });

    $('.show_single_date').click(function() {
      $('.date_range').hide();
      $('.single_date').show();
      $('.time_entry_spent_on').focus();
      $('.time_entry_spent_on').val($('.date_from').val());
      $('.date_from').val('');
      $('.date_to').val('');
    });

    $('.fill_quota').click(function() {
      $('.hours').hide();
      $('.time_entry_hours').val('');
      $('.quota').show();
      $('.quota_specified').val('true');
    });

    $('.specify_hours').click(function() {
      $('.quota').hide();
      $('.hours').show();
      $('.time_entry_hours').focus();
      $('.quota_specified').val('false');
    });
  });
})(jQuery);
