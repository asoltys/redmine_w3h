jQuery.noConflict()

# set $ to jquery instead of prototype, just in this file
(($) ->
  # root is where we store 'global' variables in coffeescript
  root = exports ? this

  # everything in here gets run on page load
  $(->
    # make a copy of the original time entry form
    root.entry = $('div#entries').children('div').first().clone(true, true)
    $('#time_entry_hours').focus()
    $('.quota_specified').val(false)
    $('form.tabular input').keypress((e) ->
      $('form.tabular').submit() if e.which == 13
    )

    # handle form submission through ajax so we don't have to reload the page
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

    # load issues on project change
    $('select[id*=project]').change(->
      target = $(this).closest('div').find('select[id*=issue_id]')
      target.attr('disabled', 'disabled')
      $.getJSON('/bulk_time_entries/load_assigned_issues', {
        project_id: $(this).val(),
        entry_id: $(this).closest('div').attr('id')
      }, (data) ->
        target.removeAttr('disabled')
        open_issues = closed_issues = ''
        $.each(data, (i, v) ->
          option = "<option value='#{v.id}'>#{v.id}: #{v.subject}</option>"
          if v.closed then closed_issues += option else open_issues += option
        )
        target.find('optgroup:first').html(open_issues)
        target.find('optgroup:last').html(closed_issues)
      )
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
