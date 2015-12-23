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
window.$model      = $model
