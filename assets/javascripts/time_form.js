jQuery.noConflict();
(function($) { 
  function setup() {
    $('a.show_range').click(function() {
      var scope = $(this).closest('div.box');
      scope.find('.single_date').hide();
      scope.find('.date_from').val($('.time_entry_spent_on').val());
      scope.find('.time_entry_spent_on').val('');
      scope.find('.date_range').show();
      scope.find('.date_from').focus();
    });

    $('a.show_single_date').click(function() {
      var scope = $(this).closest('div.box');
      scope.find('.date_range').hide();
      scope.find('.single_date').show();
      scope.find('.time_entry_spent_on').focus();
      scope.find('.time_entry_spent_on').val($('.date_from').val());
      scope.find('.date_from').val('');
      scope.find('.date_to').val('');
    });

    $('a.fill_quota').click(function() {
      var scope = $(this).closest('div.box');
      scope.find('.hours').hide();
      scope.find('.time_entry_hours').val('');
      scope.find('.quota').show();
      scope.find('.quota_specified').val('true');
    });

    $('a.specify_hours').click(function() {
      var scope = $(this).closest('div.box');
      scope.find('.quota').hide();
      scope.find('.hours').show();
      scope.find('.time_entry_hours').focus();
      scope.find('.quota_specified').val('false');
    });

    $('img.calendar-trigger').each(function() {
      Calendar.setup({
        inputField: $(this).prev('input').attr('id'), 
        ifFormat: '%Y-%m-%d', 
        button: $(this).attr('id') 
      });
    });
  }

  $(function() {
    setup();

    $('.add_entry').click(function() {
      var entry = $('div#entries').children('div').last().clone(true, true);
      var id = entry.attr('id').match(/_(.*)/)[1];
      var new_id = parseInt(id) + 1;
      var id_regex = eval('/' + id + '/g');

      $('div#entries').
        append('<div id="entry_' + new_id + '" class="box">' + entry.html().replace(id_regex, new_id) + '</div>').
        remove('div.errorExplanation');

      setup();
    });
  });
})(jQuery);
