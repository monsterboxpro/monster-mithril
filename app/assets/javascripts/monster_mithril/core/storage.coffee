class $storage
  @stack: []
  @reset: =>
    @stack = []
  @get:(k)=>
    @stack[k]
  @set:(k,v)=>
    @stack[k] = v

window.$storage = $storage
