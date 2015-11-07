if typeof _isomorphic != 'undefined'
  m.route =
    param:(key)->
      _iso_param[key]

api_loaded = false
app = { events: {}, models: {}, services: {}, util: {}, store: {}, preload: {} }
$f = {}

$loc = (n)->
  document.body.setAttribute('location',n)

$dom =
  get:(sel)->
    document.querySelectorAll(sel)
  addClass:(el,class_name)->
    if (el.classList)
      el.classList.add class_name
    else
      el.className += ' ' + class_name
  removeClass:(el,class_name)->
    if (el.classList)
      el.classList.remove(class_name)
    else
      el.className = el.className.replace(new RegExp('(^|\\b)' + class_name.split(' ').join('|') + '(\\b|$)', 'gi'), ' ')

$stop = (e)->
  e.prevDefault()     if e.prevDefault
  e.stopPropagation() if e.stopPropagation
  e.cancelBubble = true
  e.returnValue  = false

$filter = (name,definition) ->
  $f[name] = definition

$register = (_scope,name,fun)->
  app.events[name] ?= {}
  app.events[name][_scope] = fun

$broadcast = (name, data)->
  if name != "" && app.events[name]
    for key,fun of app.events[name]
      fun(data) if fun

$service = (name, args..., definition) ->
  super_def = class extends definition
    constructor:->
      super
  app.services[name] = super_def

$comp = (tag,name,data)->
  names = name.split '/'
  app.store[name] ?= {}
  #m.component app[names[0]][names[1]], data
  m tag, app[names[0]][names[1]].view(app[names[0]][names[1]].controller(data))

$popup = (name,data={},opts={})=>
  names = name.split '/'
  ctrl    = app[names[0]][names[1]].controller(data)
  content = app[names[0]][names[1]].view ctrl
  ctrl.content = content
  ctrl.opts = opts
  app.layouts.popup.view ctrl

$layout = (ctrl, content, opts={}) =>
  kind = opts.layout || 'application'
  data =
    content: content
    ctrl: ctrl
  app.layouts[kind].view data

$controller = (name, args..., definition) ->
  __fun
  names = name.split '/'
  app.store["#{names[0]}/#{names[1]}"] = {}
  app[names[0]]           ?= {}
  app[names[0]][names[1]] ?= {}
  super_def = class extends definition
    constructor:->
      @__fun       = __fun
      @$           = {}
      @_name       = name
      @_controller = names[0]
      @_action     = names[1]
      @Api = new app.services.Api()
      super
    $on: (name,fun)=>
      $register @_name, name, fun
    $export: (args...)=>
      @$[arg] = @[arg] for arg in args
    param:(name)->
      m.route.param name
    store:(val,input)=>
      key = "#{@_controller}/#{@_action}"
      if input is undefined
        app.store[key][val]
      else
        app.store[key][val] = input

  __fun = ->
    new super_def(arguments).$
  app[names[0]][names[1]].controller = __fun


$model = (name, definition) ->
  if definition
    super_def = class extends definition
      constructor:->
        @_init()
      _init:=>
        @$ =
          params: @params
          reset : @reset
        @$.id = m.prop(null)
        for k,v of @columns
          @$[k] = m.prop(v)
      params:=>
        attrs = {}
        attrs.id = @$.id()
        for k,v of @columns
          attrs[k] = @$[k]()
        attrs
      reset:=>
        @$.id(null)
        for k,v of @columns
          @$[k](v)
    __fun = ->
      new super_def().$
    app.models[name] = __fun
  else
    if app.models[name]
      new app.models[name]()
    else
      null


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

_ = {}
_.any = (arr,fun) ->
  val = false
  val = true if fun() is true for item in arr
  val
_.is_array = (input)->
  Object::toString.call(input) is '[object Array]'
_.create = (collection,data)->
  collection ||= []
  collection.push data
  data
_.update = (collection,data)->
  model = null
  for m in collection
    model = m if data.id is m.id
  i = collection.indexOf model
  return null if i is -1
  collection[i] = data
  collection[i]
_.destroy = (collection,data)->
  model = null
  for m in collection
    model = m if data.id is m.id
  i = collection.indexOf model
  return null if i is -1
  collection.splice i, 1
  model

window.$dom        = $dom
window._           = _
window.$broadcast  = $broadcast
window.$register   = $register
window.$popup      = $popup
window.$layout     = $layout
window.$loc        = $loc
window.$stop       = $stop
window.$service    = $service
window.$comp       = $comp
window.$model      = $model
window.$controller = $controller
window.$view       = $view
window.$filter     = $filter
window.$f          = $f
window.app         = app
window.api_loaded  = api_loaded
