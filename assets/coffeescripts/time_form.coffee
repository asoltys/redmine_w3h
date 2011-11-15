jQuery.noConflict()

# set $ to jquery instead of prototype, just in this file
(($) ->
  # root is where we store 'global' variables in coffeescript
  root = exports ? this

  # everything in here gets run on page load
  $(->
    # make a copy of the original time entry form
    root.entry = $('div#entries').children('div').first().clone(true, true)

    # bind all the click handlers
    setup()

    # handle form submission through ajax so we don't have to reload the page
    $('form.tabular').submit(->
      $.post('/bulk_time_entries/save', $(this).serialize(), (json) ->
        $.each(json.entries, (index, entries) ->
          
          # use the first entry to find the form
          $("#entry_#{index}").replaceWith("<div class='flash notice'>#{json.messages[index]}</div>")

          # update the calendar for each day that was logged
          $.each(entries, (i, e) ->
            e = e.time_entry
            hours = $('.' + e.spent_on + ' a').html()
            hours = parseFloat($.trim(hours)) + e.hours
            $('.' + e.spent_on + ' a').html(hours)
            $('.' + e.spent_on + ' a').effect('highlight', {color: '#9FCF9F'}, 1500)
          )
        )
      )

      # prevent the form from submitting normally
      return false
    )

    $('.add_entry').click(->
      id = root.entry.attr('id').match(/_(.*)/)[1]
      new_id = parseInt(id) + 1
      id_regex = eval('/entr(y|ies)(_|\\[)' + id + '/g')
      entry = "<div id='entry_#{new_id}' class='box'>#{root.entry.html().replace(id_regex, "entr$1$2#{new_id}")}</div>"
      $('div#entries').append(entry)

      # re-bind all the behaviours so that the new entry form gets them
      setup()
    )
  )

  setup = ->
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
      e.find('.hours input').val('1')
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
