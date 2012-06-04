
  jQuery.noConflict();

  (function($) {
    var global;
    global = this;
    return $(function() {
      var add_operations, displayCalendar, edit_operations, toggleEditMode;
      global.ctrl_down = false;
      global.xhr;
      $.ajaxSetup({
        beforeSend: function(xhr) {
          return xhr.setRequestHeader("Accept", "application/json");
        }
      });
      displayCalendar = function(response) {
        $('div#calendar').remove();
        $('form.tabular').after(response);
        return $('span.logged-time').fadeIn();
      };
      $.get('/bulk_time_entries/calendar', function(response) {
        return displayCalendar(response);
      });
      $('a#previous, a#next').live('click', function() {
        return $.get('/bulk_time_entries/calendar', {
          start: $(this).attr('class')
        }, function(response) {
          return displayCalendar(response);
        });
      });
      $('#time_entry_hours').focus().val('');
      $('input[type=button]').click(function(event) {
        return preventDefault(event);
      });
      add_operations = $('#operation option.add').clone();
      edit_operations = $('#operation option.edit').clone();
      toggleEditMode = function() {
        if ($('input[name=_method]').length > 0) {
          $('#original_hours').show();
          $('#to').show();
          return $('#operation').html(edit_operations);
        } else {
          $('#original_hours').hide();
          return $('#operation').html(add_operations);
        }
      };
      toggleEditMode();
      $('form.tabular input[type!=button], form.tabular select').keydown(function(e) {
        if (e.keyCode === 13) {
          global.prevent_click = true;
          return $('form.tabular').submit();
        }
      });
      $('form.tabular').submit(function() {
        $.post('/bulk_time_entries/save', $(this).serialize(), function(json) {
          var ids;
          $('div.box input, div.box select').removeAttr('disabled');
          if (json.message) {
            $.each(json.entries, function(i, e) {
              var hours, link;
              e = e.time_entry;
              link = $('.' + e.spent_on + ' a');
              hours = parseFloat($.trim(link.html()));
              if (isNaN(hours)) hours = 0;
              if ($('input[name=_method]').length > 0) {
                hours -= parseFloat($('#original_hours').val());
              }
              hours += e.hours;
              link.closest('span').show();
              return link.html(hours.toFixed(1)).stop(true, true).effect('highlight', {
                color: '#9FCF9F'
              }, 1500);
            });
            $('input[name=_method]').remove();
            toggleEditMode();
            $('#time_entry_hours').val('');
            ids = JSON.stringify($.map(json.entries, function(val, i) {
              return val.id;
            }));
            $('div.flash').remove();
            $('form.tabular').before('<div class="flash notice">' + json.message + '</div>');
            $('div.flash').hide().fadeIn();
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
        if (global.xhr && global.xhr.readyState !== 4) global.xhr.abort();
        $('#time_entry_issue_id').attr('disabled', 'disabled');
        $('#time_entry_deliverable_id').attr('disabled', 'disabled');
        $('#time_entry_deliverable_id option:gt(0)').remove();
        return global.xhr = $.getJSON('/bulk_time_entries/load_project_data', {
          project_id: $(this).val(),
          entry_id: $(this).closest('div').attr('id')
        }, function(data) {
          var closed_issues_options, deliverables_options, myloop, open_issues_options;
          open_issues_options = closed_issues_options = '';
          myloop = function() {
            var option, subject;
            subject = $.trim(this.subject).substring(0, 40).split(" ").slice(0, -1).join(" ");
            if (subject.length >= 39) subject += '...';
            option = "<option value='" + this.id + "'";
            if (this.id === global.time_entry.issue.id) {
              option += " selected='selected'";
            }
            option += ">" + this.id + ": " + subject + "</option>";
            if (this.closed) {
              return closed_issues_options += option;
            } else {
              return open_issues_options += option;
            }
          };
          $.each(data.issues, myloop);
          if (open_issues_options.length + closed_issues_options.length === 0) {
            $('#entry_issues').fadeOut();
            $('#time_entry_deliverable_id').focus();
          } else {
            $('#entry_issues').fadeIn();
            $('#time_entry_issue_id').removeAttr('disabled');
            $('#time_entry_issue_id optgroup:first').html(open_issues_options);
            $('#time_entry_issue_id optgroup:last').html(closed_issues_options);
          }
          deliverables_options = '';
          $.each(data.deliverables, function() {
            var option;
            option = "<option value='" + this.id + "'";
            if (this.id === global.time_entry.deliverable.id) {
              option += " selected='selected'";
            }
            option += ">" + this.subject + "</option>";
            return deliverables_options += option;
          });
          if (deliverables_options === '') {
            return $('#entry_deliverables').fadeOut();
          } else {
            $('#entry_deliverables').fadeIn();
            $('#time_entry_deliverable_id').removeAttr('disabled');
            return $('#time_entry_deliverable_id option').after(deliverables_options);
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
      $('div.box input, div.box select').removeAttr('disabled');
      if ($('#time_entry_id').length > 0) {
        $.get("/time_entries/" + ($('#time_entry_id').val()) + ".json", function(json) {
          global.time_entry = json.time_entry;
          $('#time_entry_project_id').val(global.time_entry.project.id);
          return $('select[id*=project]').change();
        });
      } else {
        $('select[id*=project]').change();
      }
      $('#show_range').click(function() {
        if (global.prevent_click) {
          global.prevent_click = false;
          return false;
        }
        $('#single_date').hide();
        $('#date_from').val($('#time_entry_spent_on').val());
        $('#date_to').val(moment($('#time_entry_spent_on').val(), 'YYYY-MM-DD').add('days', 7).format('YYYY-MM-DD'));
        $('#time_entry_spent_on').val('');
        $('#date_range').show();
        $('#date_from').focus();
        return false;
      });
      $('#show_single_date').click(function() {
        if (global.prevent_click) {
          global.prevent_click = false;
          return false;
        }
        $('#date_range').hide();
        $('#single_date').show();
        $('#time_entry_spent_on').focus();
        $('#time_entry_spent_on').val($('#date_from').val());
        $('#date_from').val('');
        $('#date_to').val('');
        return false;
      });
      $('#.specify_hours').click(function() {
        $('#hours').show();
        $('#hours input').val('');
        return $('#time_entry_hours').focus();
      });
      return $('img.calendar-trigger').each(function() {
        return Calendar.setup({
          inputField: $(this).prev('input').attr('id'),
          ifFormat: '%Y-%m-%d',
          button: $(this).attr('id')
        });
      });
    });
  })(jQuery);
