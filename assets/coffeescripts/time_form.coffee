jQuery.noConflict()
(($) ->
  root = exports ? this

  $(->
    setup()

    $('form.tabular').submit(->
      $.post('/bulk_time_entries/save', $(this).serialize(), (json) ->
        $.each(json.entries, (index, value) ->
          entry = value.time_entry
          $("#entry_#{index}").replaceWith("<div class='flash notice'>#{json.messages[index]}</div>")
        )
      )
      return false
    )

    $('.add_entry').click(->
      id = root.entry.attr('id').match(/_(.*)/)[1]
      new_id = parseInt(id) + 1
      id_regex = eval('/' + id + '/g')
      entry = "<div id='entry_#{new_id}' class='box'>#{root.entry.html().replace(id_regex, new_id)}</div>"
      $('div#entries').append(entry) 
      setup()
    )
  )

  setup = ->
    root.entry = $('div#entries').children('div').last().clone(true, true)

    $('a.show_range').click(->
      scope = $(this).closest('div.box')
      scope.find('.single_date').hide()
      scope.find('.date_from').val($('.time_entry_spent_on').val())
      scope.find('.time_entry_spent_on').val('')
      scope.find('.date_range').show()
      scope.find('.date_from').focus()
    )

    $('a.show_single_date').click(->
      scope = $(this).closest('div.box')
      scope.find('.date_range').hide()
      scope.find('.single_date').show()
      scope.find('.time_entry_spent_on').focus()
      scope.find('.time_entry_spent_on').val($('.date_from').val())
      scope.find('.date_from').val('')
      scope.find('.date_to').val('')
    )

    $('a.fill_quota').click(->
      scope = $(this).closest('div.box')
      scope.find('.hours').hide()
      scope.find('.hours input').val('1')
      scope.find('.quota').show()
      scope.find('.quota_specified').val('true')
    )

    $('a.specify_hours').click(->
      scope = $(this).closest('div.box')
      scope.find('.quota').hide()
      scope.find('.hours').show()
      scope.find('.hours input').val('')
      scope.find('.time_entry_hours').focus()
      scope.find('.quota_specified').val('false')
    )

    $('img.calendar-trigger').each(->
      Calendar.setup({
        inputField: $(this).prev('input').attr('id'),
        ifFormat: '%Y-%m-%d',
        button: $(this).attr('id')
      })
    )
)(jQuery)
