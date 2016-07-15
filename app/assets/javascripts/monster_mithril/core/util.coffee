util = {}

#RFC4122-v4 compliant...
util.generate_UUID = ()->
  d = new Date().getTime()
  if(window.performance && typeof window.performance.now == "function")
    d += performance.now()

  uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace /[xy]/g, (c)->
    r = (d + Math.random()*16)%16 | 0
    d = Math.floor(d/16)
    return (if (c=='x') then r else (r&0x3|0x8)).toString(16)

  return uuid


util.create_path = (obj, path) ->
  iterator = obj
  for key in path
    iterator[key] = {} if(typeof iterator[key] == 'undefined')
    iterator = iterator[key]
  iterator

util.extend = (target, source) ->
  target = target || {}
  for idx, prop of Object.keys source
    if (source[prop] && typeof source[prop] == 'object')
      target[prop] = Object.create(source[prop])
    else
      target[prop] = source[prop]
  target

util.each = (target, iterator) ->
  if(target instanceof Array)
    for value in target
      iterator(value)
  else
    for key, value of target
      iterator(value, key)


util.any = (arr,fun=null) ->
  val = false
  if util.is_array(arr)
    for item in arr
      if fun is null
        val = true if item is true
      else
        val = true if fun(item) is true
  val
util.find_by_id = (collection,id)->
  result = null
  for model in collection
    result = model if model.id is id
  result
util.is_array = (input)->
  Object::toString.call(input) is '[object Array]'
util.create = (collection,data,opts={})->
  collection ||= []
  if opts.reverse
    collection.unshift data
  else
    collection.push data
  data
util.update = (collection,data)->
  model = null
  for m in collection
    model = m if data.id is m.id
  i = collection.indexOf model
  return null if i is -1
  collection[i] = data
  collection[i]
util.destroy = (collection,data)->
  model = null
  for m in collection
    model = m if data.id is m.id
  i = collection.indexOf model
  return null if i is -1
  collection.splice i, 1
  model
util.last = (arr)->
  arr[arr.length=1]

window._ = {} unless window._


window._.generate_UUID ||= util.generate_UUID
window._.create_path ||= util.create_path
window._.extend     ||= util.extend
window._.each     ||= util.each
window._.any        ||= util.any
window._.find_by_id ||= util.find_by_id
window._.is_array   ||= util.is_array
window._.last       ||= util.last
window._.create  = util.create
window._.update  = util.update
window._.destroy = util.destroy
_ = window._ unless _
