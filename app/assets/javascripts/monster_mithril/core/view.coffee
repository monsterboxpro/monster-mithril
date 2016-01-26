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
    content = klass.render()
    if klass.layout
      @$loc "#{names[0]}_#{names[1]}"
      klass.layout = 'application' if klass.layout is true
      document.title = klass.title() if klass.title
      @$layout klass.$, content, layout: klass.layout
    else
      content
  app[names[0]][names[1]].view = __fun
module.exports = $view
