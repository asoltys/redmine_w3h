
  jQuery.noConflict();

  (function($) {
    var global, setup;
    global = this;
    $(function() {
      global.ctrl_down = false;
      global.xhr;
      $('#time_entry_hours').focus();
      $('.quota_specified').val(false);
      $('form.tabular input').keypress(function(e) {
        if (e.which === 13) return $('form.tabular').submit();
      });
      $('form.tabular').submit(function() {
        $.post('/bulk_time_entries/save', $(this).serialize(), function(json) {
          $('div.box input, div.box select').removeAttr('disabled');
          if (json.message) {
            $("#entry").before("<div class='flash notice'>" + json.message + "</div>");
            $.each(json.entries, function(i, e) {
              var hours, link;
              e = e.time_entry;
              link = $('.' + e.spent_on + ' a');
              hours = parseFloat($.trim(link.html()));
              if (isNaN(hours)) hours = 0;
              hours += e.hours;
              link.closest('span').show();
              link.html(hours).effect('highlight', {
                color: '#9FCF9F'
              }, 1500);
              if (hours >= parseFloat($.trim($('#quota_value').html()))) {
                return link.closest('span').removeClass('delinquent').show();
              }
            });
          }
          $('label').css('color', 'black');
          return $.each(json.errors, function(i, error) {
            return $("#time_entry_" + error).prev('label').css('color', 'red');
          });
        });
        $('div.box input, div.box select').attr('disabled', 'disabled');
        return false;
      });
      $('select[id*=project]').change(function() {
        var deliverables, issues;
        if (global.xhr && global.xhr.readyState !== 4) global.xhr.abort();
        issues = $(this).closest('div').find('select[id*=issue_id]');
        issues.attr('disabled', 'disabled');
        deliverables = $(this).closest('div').find('select[id*=deliverable_id]');
        deliverables.attr('disabled', 'disabled');
        deliverables.find('option:gt(1)').remove();
        return global.xhr = $.getJSON('/bulk_time_entries/load_project_data', {
          project_id: $(this).val(),
          entry_id: $(this).closest('div').attr('id')
        }, function(data) {
          var closed_issues_options, deliverables_options, open_issues_options;
          open_issues_options = closed_issues_options = '';
          $.each(data.issues, function(i, v) {
            var option;
            option = "<option value='" + v.id + "'>" + v.id + ": " + v.subject + "</option>";
            if (v.closed) {
              return closed_issues_options += option;
            } else {
              return open_issues_options += option;
            }
          });
          if (open_issues_options.length + closed_issues_options.length === 0) {
            $('#entry_issues').hide();
            deliverables.focus();
          } else {
            $('#entry_issues').show();
            issues.removeAttr('disabled');
            if ($('#time_entry_project_id').is(':focus')) issues.focus();
            issues.find('optgroup:first').html(open_issues_options);
            issues.find('optgroup:last').html(closed_issues_options);
          }
          deliverables_options = '';
          $.each(data.deliverables, function(i, v) {
            return deliverables_options += "<option value='" + v.id + "'>" + v.subject + "</option>";
          });
          if (deliverables_options === '') {
            return $('#entry_deliverables').hide();
          } else {
            $('#entry_deliverables').show();
            deliverables.removeAttr('disabled');
            if ($('#time_entry_project_id').is(':focus')) deliverables.focus();
            return deliverables.find('option').after(deliverables_options);
          }
        });
      });
      $('.calendar-trigger').prev('input').keydown(function(e) {
        var interval;
        interval = global.ctrl_down ? 'months' : 'days';
        switch (e.keyCode) {
          case 17:
            return global.ctrl_down = true;
          case 38:
            return $(this).val(moment($(this).val(), 'YYYY-MM-DD').add(interval, 1).format('YYYY-MM-DD'));
          case 40:
            return $(this).val(moment($(this).val(), 'YYYY-MM-DD').subtract(interval, 1).format('YYYY-MM-DD'));
        }
      }).keyup(function(e) {
        if (e.keyCode === 17) return global.ctrl_down = false;
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
