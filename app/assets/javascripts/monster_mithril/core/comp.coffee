# old and should be deperacated
$comp = (tag,name,data)->
  names = name.split '/'
  m tag, app[names[0]][names[1]].view(app[names[0]][names[1]].controller(data))
window.$comp       = $comp


$component = (name, args..., definition) ->
  __fun
  names = name.split '/'
  $$[names[0]] ?= {} unless names.length is 1
  super_def = class extends definition
    constructor:->
      store_obj = new $storage()
      @_inject args
      @__fun       = __fun
      @$           = {}
      @_name       = name
      @_controller = names[0]
      @_action     = names[1]
      @Api = new app.services.Api()
      @$store = store_obj.$store
      super
    $on: (name,fun)=>
      $register @_name, name, fun
    $export: (args...)=>
      @$[arg] = @[arg] for arg in args
    param:(name)->
      m.route.param name
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
    $storage.push_key('shared/'+name)
    ctrl = new super_def(arguments).$
    content
    if names.length is 1
      content = app.shared[names[0]].view ctrl
    else
      content = app[names[0]][names[1]].view ctrl
    content
  if names.length is 1
    $$[names[0]] = __fun
  else
    $$[names[0]][names[1]] = __fun

window.$component = $component
