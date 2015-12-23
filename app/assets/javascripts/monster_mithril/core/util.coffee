_ = {}
_.any = (arr,fun) ->
  val = false
  val = true if fun() is true for item in arr
  val
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

window._ = _
