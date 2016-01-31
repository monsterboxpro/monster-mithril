$storage = class
  constructor: (key)->
    @key = key
    @uniq_id = Math.random().toString(36).substring(7);

    if(typeof app.store[@key] == 'undefined')
      app.store[@key] = {}
    if(typeof app.store[@key][@uniq_id] == 'undefined')
      app.store[@key][@uniq_id] = {}

  $store: (val,input)=>
    if input is undefined
      app.store[@key][@uniq_id][val]
    else
      app.store[@key][@uniq_id][val] = input

window.$storage = $storage