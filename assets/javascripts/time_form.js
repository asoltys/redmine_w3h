
  jQuery.noConflict();

  (function($) {
    var global, setup;
    global = this;
    $(function() {
      global.ctrl_down = false;
      global.xhr;
      $.ajaxSetup({
        beforeSend: function(xhr) {
          return xhr.setRequestHeader("Accept", "application/json");
        }
      });
      $('#time_entry_hours').focus();
      $('form.tabular input, form.tabular select').keydown(function(e) {
        if (e.keyCode === 13) return $('form.tabular').submit();
      });
      $('form.tabular').submit(function() {
        $.post('/bulk_time_entries/save', $(this).serialize(), function(json) {
          $('div.box input, div.box select').removeAttr('disabled');
          if (json.message) {
            $("#entry").before("<div class='flash notice'>              " + json.message + "              <span style='float: right'>                <a>edit</a>                <a>undo</a>              </span>            </div>");
            $.each(json.entries, function(i, e) {
              var hours, link;
              e = e.time_entry;
              link = $('.' + e.spent_on + ' a');
              hours = parseFloat($.trim(link.html()));
              if (isNaN(hours)) hours = 0;
              hours += e.hours;
              link.closest('span').show();
              return link.html(hours).effect('highlight', {
                color: '#9FCF9F'
              }, 1500);
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
        deliverables.find('option:gt(0)').remove();
        return global.xhr = $.getJSON('/bulk_time_entries/load_project_data', {
          project_id: $(this).val(),
          entry_id: $(this).closest('div').attr('id')
        }, function(data) {
          var closed_issues_options, deliverables_options, open_issues_options;
          open_issues_options = closed_issues_options = '';
          $.each(data.issues, function(i, v) {
            var option, subject;
            subject = $.trim(v.subject).substring(0, 40).split(" ").slice(0, -1).join(" ");
            if (subject.length >= 39) subject += '...';
            option = "<option value='" + v.id + "'>" + v.id + ": " + subject + "</option>";
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
      $('select').keyup(function(e) {
        if (e.keyCode === 9) return $(this).attr('size', 10);
      }).blur(function(e) {
        return $(this).attr('size', 1);
      });
      return setup();
    });
    return setup = function() {
      $('div.box input, div.box select').removeAttr('disabled');
      $('select[id*=project]').change();
      $('button.show_range').click(function() {
        var e;
        e = $(this).closest('div.box');
        e.find('.single_date').hide();
        e.find('.date_from').val($('.time_entry_spent_on').val());
        e.find('.time_entry_spent_on').val('');
        e.find('.date_range').show();
        e.find('.date_from').focus();
        return false;
      });
      $('button.show_single_date').click(function() {
        var e;
        e = $(this).closest('div.box');
        e.find('.date_range').hide();
        e.find('.single_date').show();
        e.find('.time_entry_spent_on').focus();
        e.find('.time_entry_spent_on').val($('.date_from').val());
        e.find('.date_from').val('');
        e.find('.date_to').val('');
        return false;
      });
      $('a.specify_hours').click(function() {
        var e;
        e = $(this).closest('div.box');
        e.find('.hours').show();
        e.find('.hours input').val('');
        return e.find('.time_entry_hours').focus();
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
