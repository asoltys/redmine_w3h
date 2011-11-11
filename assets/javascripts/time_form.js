
  jQuery.noConflict();

  (function($) {
    var root, setup;
    root = typeof exports !== "undefined" && exports !== null ? exports : this;
    setup = function() {
      root.entry = $('div#entries').children('div').last().clone(true, true);
      $('a.show_range').click(function() {
        var scope;
        scope = $(this).closest('div.box');
        scope.find('.single_date').hide();
        scope.find('.date_from').val($('.time_entry_spent_on').val());
        scope.find('.time_entry_spent_on').val('');
        scope.find('.date_range').show();
        return scope.find('.date_from').focus();
      });
      $('a.show_single_date').click(function() {
        var scope;
        scope = $(this).closest('div.box');
        scope.find('.date_range').hide();
        scope.find('.single_date').show();
        scope.find('.time_entry_spent_on').focus();
        scope.find('.time_entry_spent_on').val($('.date_from').val());
        scope.find('.date_from').val('');
        return scope.find('.date_to').val('');
      });
      $('a.fill_quota').click(function() {
        var scope;
        scope = $(this).closest('div.box');
        scope.find('.hours').hide();
        scope.find('.hours input').val('1');
        scope.find('.quota').show();
        return scope.find('.quota_specified').val('true');
      });
      $('a.specify_hours').click(function() {
        var scope;
        scope = $(this).closest('div.box');
        scope.find('.quota').hide();
        scope.find('.hours').show();
        scope.find('.hours input').val('');
        scope.find('.time_entry_hours').focus();
        return scope.find('.quota_specified').val('false');
      });
      return $('img.calendar-trigger').each(function() {
        return Calendar.setup({
          inputField: $(this).prev('input').attr('id'),
          ifFormat: '%Y-%m-%d',
          button: $(this).attr('id')
        });
      });
    };
    return $(function() {
      setup();
      return $('.add_entry').click(function() {
        var id, id_regex, new_id;
        id = root.entry.attr('id').match(/_(.*)/)[1];
        new_id = parseInt(id) + 1;
        id_regex = eval('/' + id + '/g');
        $('div#entries').append('<div id="entry_' + new_id + '" class="box">' + root.entry.html().replace(id_regex, new_id) + '</div>').remove('div.errorExplanation');
        return setup();
      });
    });
  })(jQuery);
