jQuery ($) ->
  ready = ->
    $('.submit-sort-per-page').hide()
    $('.sort-per-page-dropdown').on 'change', (event) ->
      @form.submit()

  $(document).ready(ready)
  $(document).on('page:load', ready)
