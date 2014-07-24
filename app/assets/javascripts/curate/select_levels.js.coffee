#jQuery ($) ->
#  ready = ->
#    $('.autocomplete-vocab').each (index, el) ->
#      $targetElement = $(el)
#      $targetElement.autocomplete
#        source: (request, response) ->
#          $targetElement.data('url')
#          $.getJSON $targetElement.data('url'), { q: request.term }, ( data, status, xhr ) ->
#            matches = []
#            $.each data, (idx, val) ->
#              console.log("data from ajax url: "+ val)
#              matches.push {label: val['label'], value: val['id']}
#              console.log("Matches: "+ matches)
#            response( matches )
#        minLength: 2
#        focus: ( event, ui ) ->
#          $targetElement.val(ui.item.label)
#          event.preventDefault()
#        select: ( event, ui ) ->
#          $targetElement.val(ui.item.label)
#          event.preventDefault()
#
#  $(document).ready(ready)
#  $(document).on('page:load', ready)
