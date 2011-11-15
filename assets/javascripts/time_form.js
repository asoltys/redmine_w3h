
  jQuery.noConflict();

  (function($) {
    var root, setup;
    root = typeof exports !== "undefined" && exports !== null ? exports : this;
    $(function() {
      root.entry = $('div#entries').children('div').first().clone(true, true);
      setup();
      $('form.tabular').submit(function() {
        $.post('/bulk_time_entries/save', $(this).serialize(), function(json) {
          if (!$.isEmptyObject(json.messages)) {
            $.each(json.entries, function(index, entries) {
              $("#entry_" + index).replaceWith("<div class='flash notice'>" + json.messages[index] + "</div>");
              return $.each(entries, function(i, e) {
                var hours;
                e = e.time_entry;
                hours = $('.' + e.spent_on + ' a').html();
                hours = parseFloat($.trim(hours)) + e.hours;
                $('.' + e.spent_on + ' a').html(hours);
                return $('.' + e.spent_on + ' a').effect('highlight', {
                  color: '#9FCF9F'
                }, 1500);
              });
            });
          }
          $('label').css('color', 'black');
          return $.each(json.errors, function(i, errors) {
            return $.each(errors, function(j, error) {
              return $("#time_entries_" + i + "_" + error[0]).prev('label').css('color', 'red');
            });
          });
        });
        return false;
      });
      return $('.add_entry').click(function() {
        var entry, id, id_regex, new_id;
        id = root.entry.attr('id').match(/_(.*)/)[1];
        new_id = parseInt(id) + 1;
        id_regex = eval('/entr(y|ies)(_|\\[)' + id + '/g');
        entry = "<div id='entry_" + new_id + "' class='box'>" + (root.entry.html().replace(id_regex, "entr$1$2" + new_id)) + "</div>";
        $('div#entries').append(entry);
        root.entry = entry.clone(true, true);
        return setup();
      });
    });
    return setup = function() {
      $('a.show_range').click(function() {
        var e;
        e = $(this).closest('div.box');
        e.find('.single_date').hide();
        e.find('.date_from').val($('.time_entry_spent_on').val());
        e.find('.time_entry_spent_on').val('');
        e.find('.date_range').show();
        return e.find('.date_from').focus();
      });
      $('a.show_single_date').click(function() {
        var e;
        e = $(this).closest('div.box');
        e.find('.date_range').hide();
        e.find('.single_date').show();
        e.find('.time_entry_spent_on').focus();
        e.find('.time_entry_spent_on').val($('.date_from').val());
        e.find('.date_from').val('');
        return e.find('.date_to').val('');
      });
      $('a.fill_quota').click(function() {
        var e;
        e = $(this).closest('div.box');
        e.find('.hours').hide();
        e.find('.hours input').val('1');
        e.find('.quota').show();
        return e.find('.quota_specified').val('true');
      });
      $('a.specify_hours').click(function() {
        var e;
        e = $(this).closest('div.box');
        e.find('.quota').hide();
        e.find('.hours').show();
        e.find('.hours input').val('');
        e.find('.time_entry_hours').focus();
        return e.find('.quota_specified').val('false');
      });
      return $('img.calendar-trigger').each(function() {
        return Calendar.setup({
          inputField: $(this).prev('input').attr('id'),
          ifFormat: '%Y-%m-%d',
          button: $(this).attr('id')
        });
      });
    };
  })(jQuery);
