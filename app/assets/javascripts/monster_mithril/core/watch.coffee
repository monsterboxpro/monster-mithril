$watch = (store, callback) ->
  (value) ->
    if arguments.length is 0
      store()
    else
      store value
      callback value
window.$watch = $watch
