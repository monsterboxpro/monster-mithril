module.exports =

  "$broadcast": (name, data)->
    if name != "" && app.events[name]
      for key,fun of app.events[name]
        fun(data) if fun

  "$register": (_scope, name, fun)->
    app.events[name] ?= {}
    app.events[name][_scope] = fun
