jQuery.noConflict()
(($) ->
  global = this

  $(->
    global.ctrl_down = false
    global.xhr

    # make sure we ask for JSON explicitly
    $.ajaxSetup({
      beforeSend: (xhr) ->
        xhr.setRequestHeader("Accept", "application/json")
    })

    $('span.logged-time').show()
    $('#time_entry_hours').focus()

    $('input[type=button]').click((event) ->
      preventDefault(event)
    )

    # don't toggle range on enter
    $('form.tabular input[type!=button], form.tabular select').keydown((e) ->
      if e.keyCode == 13
        $('button').unbind('click')
    )

    $('form.tabular').submit(->
      $.post('/bulk_time_entries/save', $(this).serialize(), (json) ->
        $('div.box input, div.box select').removeAttr('disabled')

        if json.message
          # update the calendar for each day that was logged
          $.each(json.entries, (i, e) ->
            e = e.time_entry
            link = $('.' + e.spent_on + ' a')
            hours = parseFloat($.trim(link.html()))
            hours = 0 if isNaN(hours)
            hours += e.hours
            link.closest('span').show()
            link.html(hours).stop(true, true).effect('highlight', {color: '#9FCF9F'}, 1500)
          )

          ids = JSON.stringify($.map(json.entries, (val, i) ->
            return val.id
          ))

          $("#entry").before('
            <div class="flash notice">' +
              json.message + '
              <span style="float: right">
                <a class="icon icon-edit">edit</a>
                <a class="icon icon-del">undo</a>
                <a class="icon icon-check">dismiss</a>
              </span>
            </div>
          ')

        # highlight fields with validation errors
        $('label').css('color', 'black')
        $.each(json.errors, (i, error) ->
          $("#time_entry_#{error}").prev('label').css('color', 'red')
        )
      )

      # disable the form until the AJAX succeeds
      $('div.box input, div.box select').attr('disabled', 'disabled')

      # prevent form submission
      return false
    )

    # load issues and deliverables on project change
    $('select[id*=project]').change(->

      # if some AJAX is already underway, cancel it cuz the params be changin'
      if global.xhr && global.xhr.readyState != 4
        global.xhr.abort()

      $('#time_entry_issue_id').attr('disabled', 'disabled')

      $('#time_entry_deliverable_id').attr('disabled', 'disabled')
      $('#time_entry_deliverable_id option:gt(0)').remove()

      global.xhr = $.getJSON('/bulk_time_entries/load_project_data', {
        project_id: $(this).val(),
        entry_id: $(this).closest('div').attr('id')
      }, (data) ->
        open_issues_options = closed_issues_options = ''
        $.each(data.issues, (i, v) ->
          subject = $.trim(v.subject).substring(0, 40).split(" ").slice(0, -1).join(" ")
          subject += '...' if subject.length >= 39
          option = "<option value='#{v.id}'>#{v.id}: #{subject}</option>"
          if v.closed 
            closed_issues_options += option 
          else 
            open_issues_options += option
        )
        
        if open_issues_options.length + closed_issues_options.length == 0
          $('#entry_issues').hide() 
          $('#time_entry_deliverable_id').focus()
        else
          $('#entry_issues').show()
          $('#time_entry_issue_id').removeAttr('disabled')
          $('#time_entry_issue_id optgroup:first').html(open_issues_options)
          $('#time_entry_issue_id optgroup:last').html(closed_issues_options)

        deliverables_options = ''
        $.each(data.deliverables, (i, v) ->
          deliverables_options += "<option value='#{v.id}'>#{v.subject}</option>"
        )

        if deliverables_options == ''
          $('#entry_deliverables').hide()
        else
          $('#entry_deliverables').show()
          $('#time_entry_deliverable_id').removeAttr('disabled')
          $('#time_entry_deliverable_id option').after(deliverables_options)
      )
    )

    $('.calendar-trigger').prev('input').keydown((e) ->
      interval = if global.ctrl_down then 'months' else 'days'

      switch e.keyCode
        when 17 then global.ctrl_down = true
        when 38 then $(this).val(moment($(this).val(), 'YYYY-MM-DD').add(interval, 1).format('YYYY-MM-DD'))
        when 40 then $(this).val(moment($(this).val(), 'YYYY-MM-DD').subtract(interval, 1).format('YYYY-MM-DD'))
    ).keyup((e) ->
      global.ctrl_down = false if e.keyCode == 17
    )

    $('select').keyup((e) ->
      $(this).attr('size', 10) if e.keyCode == 9
    ).blur((e) ->
      $(this).attr('size', 1)
    )

    $('div.box input, div.box select').removeAttr('disabled')
    $('select[id*=project]').change()

    $('#show_range').click(->
      $('#single_date').hide()
      $('#date_from').val($('#time_entry_spent_on').val())
      $('#time_entry_spent_on').val('')
      $('#date_range').show()
      $('#date_from').focus()
      return false
    )

    $('#show_single_date').click(->
      $('#date_range').hide()
      $('#single_date').show()
      $('#time_entry_spent_on').focus()
      $('#time_entry_spent_on').val($('#date_from').val())
      $('#date_from').val('')
      $('#date_to').val('')
      return false
    )

    $('#.specify_hours').click(->
      $('#hours').show()
      $('#hours input').val('')
      $('#time_entry_hours').focus()
    )

    $('img.calendar-trigger').each(->
      Calendar.setup({
        inputField: $(this).prev('input').attr('id'),
        ifFormat: '%Y-%m-%d',
        button: $(this).attr('id')
      })
    )
  )
)(jQuery)
