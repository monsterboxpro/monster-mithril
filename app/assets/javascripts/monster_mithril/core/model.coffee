$model = (name, definition) ->
  if typeof(definition) is 'function'
    super_def = class extends definition
      constructor:(attrs={})->
        @_init(attrs)
      _init:(attrs)=>
        @$ =
          _kind: name
          params: @params
          reset : @reset
        @$.id = m.prop(attrs.id || null)
        for k,v of @columns
          val = attrs[k] || v
          @$[k] = m.prop(val)
      params:=>
        attrs = {}
        attrs.id = @$.id()
        for k,v of @columns
          attrs[k] = @$[k]()
        attrs
      reset:(attrs={})=>
        @$.id(attrs.id || null)
        for k,v of @columns
          val = attrs[k] || v
          @$[k](val)
    __fun = (attrs)->
      new super_def(attrs).$
    app.models[name] = __fun
  else
    if app.models[name]
      new app.models[name](definition)
    else
      null
window.$model = $model
