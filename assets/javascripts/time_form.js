
  jQuery.noConflict();

  (function($) {
    var root, setup;
    root = typeof exports !== "undefined" && exports !== null ? exports : this;
    $(function() {
      root.entry = $('div#entries').children('div').first().clone(true, true);
      $('.hours').focus();
      $('form.tabular').submit(function() {
        $.post('/bulk_time_entries/save', $(this).serialize(), function(json) {
          $('div.box input, div.box select').removeAttr('disabled');
          if (!$.isEmptyObject(json.messages)) {
            $.each(json.entries, function(index, entries) {
              $("#entry").prepend("<div class='flash notice'>" + json.messages[index] + "</div>");
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
        $('div.box input, div.box select').attr('disabled', 'disabled');
        return false;
      });
      $('select[id*=project]').change(function() {
        var target;
        target = $(this).closest('div').find('select[id*=issue_id]');
        target.attr('disabled', 'disabled');
        return $.getJSON('/bulk_time_entries/load_assigned_issues', {
          project_id: $(this).val(),
          entry_id: $(this).closest('div').attr('id')
        }, function(data) {
          var closed_issues, open_issues;
          target.removeAttr('disabled');
          open_issues = closed_issues = '';
          $.each(data, function(i, v) {
            var option;
            option = "<option value='" + v.id + "'>" + v.id + ": " + v.subject + "</option>";
            if (v.closed) {
              return closed_issues += option;
            } else {
              return open_issues += option;
            }
          });
          target.find('optgroup:first').html(open_issues);
          return target.find('optgroup:last').html(closed_issues);
        });
      });
      return setup();
    });
    return setup = function() {
      $('div.box input, div.box select').removeAttr('disabled');
      $('select[id*=project]').change();
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
