# We may want to use this in the future
# https://github.com/ljharb/qs
$location = ->
  pairs = location.search.slice(1).split('&')
  result = {}
  pairs.forEach (pair) ->
    pair = pair.split('=')
    result[pair[0]] = decodeURIComponent(pair[1] or '')
    return
  json = JSON.parse JSON.stringify(result)
  for k,v in json
    delete json[k] unless k

window.$location = $location
