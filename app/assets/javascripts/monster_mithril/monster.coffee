if typeof _isomorphic != 'undefined'
  m.route =
    param:(key)->
      app.param[key]

api_loaded = false
app        = { services: {}, util: {}, store: {}, preload: {} }

$dom =
  get:(sel)->
    document.querySelectorAll(sel)
  addClass:->
  removeClass:->

$stop = (e)->
  e.prevDefault()     if e.prevDefault
  e.stopPropagation() if e.stopPropagation
  e.cancelBubble = true
  e.returnValue  = false

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
      @_controller = names[0]
      @_action     = names[1]
      @Api = new app.services.Api
      super
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

$view = (name,fun) ->
  names = name.split '/'
  app[names[0]]           ?= {}
  app[names[0]][names[1]] ?= {}
  app[names[0]][names[1]].view = fun

window.$dom        = $dom
window.$stop       = $stop
window.$service    = $service
window.$comp       = $comp
window.$controller = $controller
window.$view       = $view
window.app         = app
window.api_loaded  = api_loaded
