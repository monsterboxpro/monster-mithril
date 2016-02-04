util = {}
util.extend = (target, source) ->
  target = target || {}
  for idx, prop of Object.keys source
    if (typeof source[prop] == 'object')
      target[prop] = util.extend(target[prop], source[prop])
    else
      target[prop] = source[prop]
  target

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

window._.extend     ||= util.extend
window._.any        ||= util.any
window._.find_by_id ||= util.find_by_id
window._.is_array   ||= util.is_array
window._.last       ||= util.last
window._.create  = util.create
window._.update  = util.update
window._.destroy = util.destroy
_ = window._ unless _
