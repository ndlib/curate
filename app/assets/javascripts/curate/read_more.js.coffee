jQuery ($) ->
  ready = ->
    $('dd.readmore').readmore({
      maxHeight: 40
      moreLink: '<a href="" title="Click for more details"><i class="icon-plus icon-large show-details"></i></a>'
      lessLink: '<a href="" title="Click for more details"><i class="icon-minus icon-large show-details"></i></a>'
    })

  $(document).ready(ready)
  $(document).on('page:load', ready)

