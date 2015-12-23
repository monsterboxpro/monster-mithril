$view = (name, definition) ->
  names = name.split '/'
  app[names[0]]           ?= {}
  app[names[0]][names[1]] ?= {}
  super_def = class extends definition
    constructor:(ctrl)->
      @$ = ctrl
    param:(name)->
      m.route.param name
  __fun = (ctrl)->
    klass = new super_def(ctrl)
    klass.render()
  app[names[0]][names[1]].view = __fun
window.$view = $view
