jQuery ->
  $(document).on "click",'.pagination a[data-remote=true]', (e) ->
    history.pushState {}, '', $(@).attr('href')