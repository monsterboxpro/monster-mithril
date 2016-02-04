if typeof _isomorphic != 'undefined'
  m.route = ->
    _iso_path
  m.route.param =(key)->
    _iso_param[key]

api_loaded = false
$$  = {}
app =
  events   : {}
  models   : {}
  services : {}
  util     : {}
  store    : {}
  preload  : {}
  mixins   : {}

window.$$          = {}
window.app         = app
window.api_loaded  = api_loaded
