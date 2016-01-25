$mixin = (name, definition) ->
  if definition
    app.mixins[name] = definition
  else
    app.mixins[name]

window.$mixin = $mixin