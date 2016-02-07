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
    in_stack = _.any $storage.stack, (item)->
      item == name
    if not in_stack
      $storage.push_key name
    klass = new super_def(ctrl)
    content = klass.render()
    if klass.layout
      $loc "#{names[0]}_#{names[1]}"
      klass.layout = 'application' if klass.layout is true
      document.title = klass.title() if klass.title
      content = $layout klass.$, content, layout: klass.layout
    $storage.pop_key()
    content
  app[names[0]][names[1]].view = __fun
window.$view = $view
