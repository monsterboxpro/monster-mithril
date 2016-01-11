# We may want to use this in the future
# https://github.com/ljharb/qs
$location = ->
  pairs = location.search.slice(1).split('&')
  result = {}
  for pair in pairs
    p = pair.split('=')
    result[p[0]] = decodeURIComponent(p[1] or '')
  result

window.$location = $location
