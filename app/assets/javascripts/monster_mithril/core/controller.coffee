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
      @clear ||= false
      if @clear is false
        app.events = {} 
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
      @_scope() unless @scope
      fun = @["#{name.replace(/\//,'_')}_success"] unless fun
      $register @scope, name, fun
    $pop: (name,opts={})=>
      vals    = name.split('/')
      ctrl    = vals[0]
      action  = vals[1]
      form    = action in ['new','edit','form']
      _action = if form then 'form' else action
      model   = if form then ctrl else "#{ctrl.singularize()}_#{action}"
      model   = model.classify()

      key = "#{ctrl}_#{_action}"
      @$[key]       = opts
      @$[key].pop   = m.prop false
      @$[key].title = m.prop ''
      @$[key].model = $model(model)

      pop_action = (model)=>
        =>
          @_check_model key
          @$[key].model.reset()
          $broadcast "#{ctrl}/#{_action}#pop", model: model
          return false

      ctx = @$.pop[ctrl]
      if ctrl is @_controller
        if form
          @$.pop.new  = pop_action
          @$.pop.edit = pop_action
          @$on "#{ctrl}/create", @create_success
          @$on "#{ctrl}/update", @update_success
        else
          @$.pop[action] = pop_action
          @$on "#{ctrl}/#{action}", @["#{action}_success"]
      else
        if form
          @$.pop[ctrl] ||= {}
          @$.pop[ctrl].new  = pop_action
          @$.pop[ctrl].edit = pop_action
          #@["#{ctrl}_create_success"] = (data)=> _.create @$.model[ctrl], data
          #@["#{ctrl}_update_success"] = (data)=> _.update @$.model[ctrl], data
          @$on "#{ctrl}/create"
          @$on "#{ctrl}/update"
        else
          @$.pop[ctrl][action] = pop_action
          @$on "#{ctrl}/#{action}"

    _check_model:(name)=>
      ctrl = "#{@_controller}/#{@_action}"
      unless @$[name]
        console.log "[List][#{ctrl}] @$", @$
        throw "[List][#{ctrl}] pop action expects #{name} to defined on scope"
      unless @$[name].model
        console.log "[List][#{ctrl}] @$.#{name}", @$[name]
        throw "[List][#{ctrl}] pop action expects a model for #{name} to defined on scope" 
    _scope:=>
      @scope = @_name + @$store('_UUID')
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
