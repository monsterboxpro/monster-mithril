$comp = (tag,name,data)->
  names = name.split '/'
  app.store[name] ?= {}
  #m.component app[names[0]][names[1]], data
  m tag, app[names[0]][names[1]].view(app[names[0]][names[1]].controller(data))
window.$comp       = $comp
