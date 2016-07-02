class $storage
  @stack: []
  @index: 0

  @push_key: (key)=>
    $storage.stack.push key
  @pop_key: =>
    $storage.stack.pop()

  constructor: (name)->
    if($storage.stack.length == 0)
      $storage.index = 0

    $storage.push_key(name)

    @container = {}

    leaf = _.create_path(app.store, $storage.stack)

    if(leaf._instances is undefined)
      leaf._instances = {}

    if(leaf._instances[$storage.index] is undefined)
      leaf._instances[$storage.index] = @container
      @container._UUID = _.generate_UUID()
      @container._stack = $storage.stack.slice(0)
      @container._instance = $storage.index
    else
      @container = leaf._instances[$storage.index]

    $storage.index += 1

  $store: (val,input)=>
    if(val is undefined and input is undefined)
      return @container
    else if(input is undefined)
      @container[val]
    else
      @container[val] = input

window.$storage = $storage