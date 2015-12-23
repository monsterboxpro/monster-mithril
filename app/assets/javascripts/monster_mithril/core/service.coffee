$service = (name, args..., definition) ->
  super_def = class extends definition
    constructor:->
      super
  app.services[name] = super_def

window.$service    = $service
