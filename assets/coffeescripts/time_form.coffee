jQuery.noConflict()
(($) ->
  global = this

  $(->
    global.ctrl_down = false
    global.xhr

    # make sure we ask for JSON explicitly
    $.ajaxSetup(
      beforeSend: (xhr) ->
        xhr.setRequestHeader("Accept", "application/json")
    )

    displayCalendar = (response) ->
      $('div#calendar').remove()
      $('form.tabular').after(response)
      $('span.logged-time').fadeIn()

    $.get('/bulk_time_entries/calendar', (response) ->
      displayCalendar(response)
    )

    $('a#previous, a#next').live('click', ->
      $.get('/bulk_time_entries/calendar', start: $(this).attr('class'), (response) ->
        displayCalendar(response)
      )
    )

    $('#time_entry_hours').focus().val('')

    $('input[type=button]').click((event) ->
      preventDefault(event)
    )

    add_operations = $('#operation option.add').clone()
    edit_operations = $('#operation option.edit').clone()

    toggleEditMode = ->
      if $('input[name=_method]').length > 0
        $('#original_hours').show()
        $('#to').show()
        $('#operation').html(edit_operations)
      else
        $('#original_hours').hide()
        $('#operation').html(add_operations)

    toggleEditMode()

    # don't toggle range on enter
    $('form.tabular input[type!=button], form.tabular select').keydown((e) ->
      if (e.keyCode == 13)
        global.prevent_click = true
        $('form.tabular').submit()
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
            if $('input[name=_method]').length > 0
              hours -= parseFloat($('#original_hours').val())
            hours += e.hours
            link.closest('span').show()
            link.html(hours.toFixed(1)).stop(true, true).effect('highlight', color: '#9FCF9F', 1500)
          )

          $('input[name=_method]').remove()
          toggleEditMode()
          $('#time_entry_hours').val('')

          ids = JSON.stringify($.map(json.entries, (val, i) ->
            return val.id
          ))

          $('div.flash').remove()
          $('form.tabular').before(
            '<div class="flash notice">' +
              json.message + 
            '</div>'
          )
          $('div.flash').hide().fadeIn()

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

      global.xhr = $.getJSON('/bulk_time_entries/load_project_data', 
        project_id: $(this).val(),
        entry_id: $(this).closest('div').attr('id')
      , (data) ->
        open_issues_options = closed_issues_options = ''

        myloop = ->
          subject = $.trim(this.subject).substring(0, 40).split(" ").slice(0, -1).join(" ")
          subject += '...' if subject.length >= 39
          option = "<option value='#{this.id}'"

          if this.id == global.time_entry.issue.id
            option += " selected='selected'"

          option += ">#{this.id}: #{subject}</option>"

          if this.closed 
            closed_issues_options += option 
          else 
            open_issues_options += option

        $.each(data.issues, myloop)
        
        if open_issues_options.length + closed_issues_options.length == 0
          $('#entry_issues').fadeOut() 
          $('#time_entry_deliverable_id').focus()
        else
          $('#entry_issues').fadeIn()
          $('#time_entry_issue_id').removeAttr('disabled')
          $('#time_entry_issue_id optgroup:first').html(open_issues_options)
          $('#time_entry_issue_id optgroup:last').html(closed_issues_options)

        deliverables_options = ''
        $.each(data.deliverables, ->
          option = "<option value='#{this.id}'"

          if this.id == global.time_entry.deliverable.id
            option += " selected='selected'"

          option += ">#{this.subject}</option>"
          deliverables_options += option
        )

        if deliverables_options == ''
          $('#entry_deliverables').fadeOut()
        else
          $('#entry_deliverables').fadeIn()
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

    $('div.box input, div.box select').removeAttr('disabled')

    if $('#time_entry_id').length > 0
      $.get("/time_entries/#{$('#time_entry_id').val()}.json", (json) ->
        global.time_entry = json.time_entry
        $('#time_entry_project_id').val(global.time_entry.project.id) 
        $('select[id*=project]').change()
      )
    else
      $('select[id*=project]').change()

    $('#show_range').click(->
      if global.prevent_click
        global.prevent_click = false
        return false

      $('#single_date').hide()
      $('#date_from').val($('#time_entry_spent_on').val())
      $('#date_to').val(moment($('#time_entry_spent_on').val(), 'YYYY-MM-DD').add('days', 7).format('YYYY-MM-DD'))
      $('#time_entry_spent_on').val('')
      $('#date_range').show()
      $('#date_from').focus()
      return false
    )

    $('#show_single_date').click(->
      if global.prevent_click
        global.prevent_click = false
        return false

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
      Calendar.setup(
        inputField: $(this).prev('input').attr('id'),
        ifFormat: '%Y-%m-%d',
        button: $(this).attr('id')
      )
    )
  )
)(jQuery)
