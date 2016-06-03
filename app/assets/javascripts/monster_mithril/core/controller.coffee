# Naming your controller
# controllers should be name <controller>/<action> eg.
# $controller 'tasks/index', class
# This will assign your controller to app eg. app.tasks.index
#
# $ - Scope
# The $ variable is a json object that will be passed onto the view. 
# So whatever you want o make avaliable to your view you need to assign
# in $ eg.
#
#  $controller 'projects/index', class
#    constructor:->
#      @$ =
#        hello: 'world'
#
# $on - Listing to Events
#
#
# $export - Assign methods to scope
#

$controller = (name, args..., definition) ->
  __fun
  names = name.split '/'
  app[names[0]]           ?= {}
  app[names[0]][names[1]] ?= {}
  super_def = class extends definition
    constructor:->
      @_inject args
      @__fun       = __fun
      @$           = {}
      @_name       = name
      @_controller = names[0]
      @_action     = names[1]
      @Api = new app.services.Api()
      @$store = new $storage(name).$store
      super
    $on: (name,fun)=>
      scope = @_name + @$store('_UUID')
      $register scope, name, fun
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
  __fun = ->
    new super_def(arguments).$
  app[names[0]][names[1]].controller = __fun

window.$controller = $controller
