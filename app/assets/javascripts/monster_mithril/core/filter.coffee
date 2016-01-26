$f = {}

module.exports =
  "$filter": (name,definition) ->
    $f[name] = definition
  "$f": $f
