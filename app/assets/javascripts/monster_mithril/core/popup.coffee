$popup = (name,data={},opts={})=>
  names = name.split '/'
  ctrl    = app[names[0]][names[1]].controller(data)
  content = app[names[0]][names[1]].view ctrl
  ctrl.content = content
  ctrl.opts = opts
  app.layouts.popup.view ctrl
module.exports = $popup
