$register = (_scope,name,fun)->
  app.events[name] ?= {}
  app.events[name][_scope] = fun

$broadcast = (name, args...)->
  if name != "" && app.events[name]
    for key,fun of app.events[name]
      fun(args...) if fun
window.$broadcast  = $broadcast
window.$register   = $register
