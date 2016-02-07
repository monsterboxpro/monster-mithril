class $storage
  @stack: []
  @index: 0
  @push_key: (key)=>
    if($storage.stack.length == 0)
      $storage.index = 0
    $storage.stack.push key
  @pop_key: =>
    $storage.stack.pop()
  constructor: ()->
    @container = {}

    leaf = _.create_path(app.store, $storage.stack)

    if(typeof leaf._instances == 'undefined')
      leaf._instances = {}

    if(typeof leaf._instances[$storage.index] == 'undefined')
      leaf._instances[$storage.index] = @container
    else
      @container = leaf._instances[$storage.index]

    $storage.index += 1

  $store: (val,input)=>
    if input is undefined
      @container[val]
    else
      @container[val] = input

window.$storage = $storage