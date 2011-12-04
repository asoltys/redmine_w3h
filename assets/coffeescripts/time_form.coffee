jQuery.noConflict()

# set $ to jquery instead of prototype, just in this file
(($) ->
  global = this

  $(->
    global.ctrl_down = false
    global.xhr

    $('#time_entry_hours').focus()
    $('.quota_specified').val(false)

    $('form.tabular input').keypress((e) ->
      $('form.tabular').submit() if e.which == 13
    )

    $('form.tabular').submit(->
      $.post('/bulk_time_entries/save', $(this).serialize(), (json) ->
        $('div.box input, div.box select').removeAttr('disabled')

        if json.message
          $("#entry").before("<div class='flash notice'>#{json.message}</div>")

          # update the calendar for each day that was logged
          $.each(json.entries, (i, e) ->
            e = e.time_entry
            link = $('.' + e.spent_on + ' a')
            hours = parseFloat($.trim(link.html()))
            hours = 0 if isNaN(hours)
            hours += e.hours
            link.closest('span').show()
            link.html(hours).effect('highlight', {color: '#9FCF9F'}, 1500)
            if hours >= parseFloat($.trim($('#quota_value').html()))
              link.closest('span').removeClass('delinquent').show()
          )

        $('label').css('color', 'black')
        $.each(json.errors, (i, error) ->
          $("#time_entry_#{error}").prev('label').css('color', 'red')
        )
      )

      $('div.box input, div.box select').attr('disabled', 'disabled')

      # prevent the form from submitting normally
      return false
    )

    # load issues and deliverables on project change
    $('select[id*=project]').change(->
      if global.xhr && global.xhr.readyState != 4
        global.xhr.abort()

      issues = $(this).closest('div').find('select[id*=issue_id]')
      issues.attr('disabled', 'disabled')

      deliverables = $(this).closest('div').find('select[id*=deliverable_id]')
      deliverables.attr('disabled', 'disabled')
      deliverables.find('option:gt(1)').remove()

      global.xhr = $.getJSON('/bulk_time_entries/load_project_data', {
        project_id: $(this).val(),
        entry_id: $(this).closest('div').attr('id')
      }, (data) ->
        open_issues_options = closed_issues_options = ''
        $.each(data.issues, (i, v) ->
          option = "<option value='#{v.id}'>#{v.id}: #{v.subject}</option>"
          if v.closed 
            closed_issues_options += option 
          else 
            open_issues_options += option
        )
        
        if open_issues_options.length + closed_issues_options.length == 0
          $('#entry_issues').hide() 
          deliverables.focus()
        else
          $('#entry_issues').show()
          issues.removeAttr('disabled')
          issues.focus() if $('#time_entry_project_id').is(':focus')
          issues.find('optgroup:first').html(open_issues_options)
          issues.find('optgroup:last').html(closed_issues_options)

        deliverables_options = ''
        $.each(data.deliverables, (i, v) ->
          deliverables_options += "<option value='#{v.id}'>#{v.subject}</option>"
        )

        if deliverables_options == ''
          $('#entry_deliverables').hide()
        else
          $('#entry_deliverables').show()
          deliverables.removeAttr('disabled')
          deliverables.focus() if $('#time_entry_project_id').is(':focus')
          deliverables.find('option').after(deliverables_options)
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
    ).keydown((e) ->
      $(this).attr('size', 1) if e.keyCode == 9
    )


    # bind all the click handlers
    setup()
  )

  setup = ->
    $('div.box input, div.box select').removeAttr('disabled')
    $('select[id*=project]').change()

    $('a.show_range').click(->
      e = $(this).closest('div.box')
      e.find('.single_date').hide()
      e.find('.date_from').val($('.time_entry_spent_on').val())
      e.find('.time_entry_spent_on').val('')
      e.find('.date_range').show()
      e.find('.date_from').focus()
    )

    $('a.show_single_date').click(->
      e = $(this).closest('div.box')
      e.find('.date_range').hide()
      e.find('.single_date').show()
      e.find('.time_entry_spent_on').focus()
      e.find('.time_entry_spent_on').val($('.date_from').val())
      e.find('.date_from').val('')
      e.find('.date_to').val('')
    )

    $('a.fill_quota').click(->
      e = $(this).closest('div.box')
      e.find('.hours').hide()
      e.find('.quota').show()
      e.find('.quota_specified').val('true')
    )

    $('a.specify_hours').click(->
      e = $(this).closest('div.box')
      e.find('.quota').hide()
      e.find('.hours').show()
      e.find('.hours input').val('')
      e.find('.time_entry_hours').focus()
      e.find('.quota_specified').val('false')
    )

    $('img.calendar-trigger').each(->
      Calendar.setup({
        inputField: $(this).prev('input').attr('id'),
        ifFormat: '%Y-%m-%d',
        button: $(this).attr('id')
      })
    )
)(jQuery)
