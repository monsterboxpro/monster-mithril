# old and should be deperacated
$comp = (tag,name,data)->
  names = name.split '/'
  app.store[name] ?= {}
  #m.component app[names[0]][names[1]], data
  m tag, app[names[0]][names[1]].view(app[names[0]][names[1]].controller(data))
window.$comp       = $comp


$component = (name, args..., definition) ->
  __fun
  names = name.split '/'
  app.store["#{names[0]}/#{names[1]}"] = {}
  $$[names[0]] ?= {} unless names.length is 1
  super_def = class extends definition
    constructor:->
      @_inject args
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
    _inject:(args)=>
      for arg_name in args
        if typeof arg_name is 'object'
          for attr of arg_name
            @[arg_name[attr]] = new app.services[arg_name[attr]]
        else
          @[arg_name] = new app.services[arg_name]
  __fun = ()->
    # Would be nice to be able to use splat eg. arguments...
    # https://github.com/jashkenas/coffeescript/issues/2183
    ctrl = new super_def(arguments).$
    if names.length is 1
      app.shared[names[0]].view ctrl
    else
      app[names[0]][names[1]].view ctrl
  if names.length is 1
    $$[names[0]] = __fun
  else
    $$[names[0]][names[1]] = __fun

window.$component = $component
