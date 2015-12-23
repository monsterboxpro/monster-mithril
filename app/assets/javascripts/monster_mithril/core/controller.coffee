set_args = (target,args) ->
  for arg_name in args
    if typeof arg_name is 'object'
      for attr of arg_name
        target[arg_name[attr]] = new app.services[arg_name[attr]]
    else
      target[arg_name] = new app.services[arg_name]

$controller = (name, args..., definition) ->
  __fun
  names = name.split '/'
  app.store["#{names[0]}/#{names[1]}"] = {}
  app[names[0]]           ?= {}
  app[names[0]][names[1]] ?= {}
  super_def = class extends definition
    constructor:->
      set_args @, args
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

window.$controller = $controller
