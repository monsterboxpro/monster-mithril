_ = {}

_.extend = (target, source) ->
  target = target || {}
  for idx, prop of Object.keys source
    if (typeof source[prop] == 'object')
      target[prop] = _.extend(target[prop], source[prop])
    else
      target[prop] = source[prop]
  target

_.any = (arr,fun=null) ->
  val = false
  if _.is_array(arr)
    for item in arr
      if fun is null
        val = true if item is true
      else
        val = true if fun(item) is true
  val
_.find_by_id = (collection,id)->
  result = null
  for model in collection
    result = model if model.id is id
  result
_.is_array = (input)->
  Object::toString.call(input) is '[object Array]'
_.create = (collection,data)->
  collection ||= []
  collection.push data
  data
_.update = (collection,data)->
  model = null
  for m in collection
    model = m if data.id is m.id
  i = collection.indexOf model
  return null if i is -1
  collection[i] = data
  collection[i]
_.destroy = (collection,data)->
  model = null
  for m in collection
    model = m if data.id is m.id
  i = collection.indexOf model
  return null if i is -1
  collection.splice i, 1
  model
_.last = (arr)->
  arr[arr.length=1]

window._ = _
