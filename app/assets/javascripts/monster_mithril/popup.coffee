class Popup
  pull: false
  params:=>
    attrs = {}
    attrs["#{@_controller}"] = @$.model.params()
    attrs
  attrs:=> {}
  constructor:(args)->
    name = "#{@_controller}_#{@_action}"
    @$.popup_class = "#{name}_popup"
    @$.model = args[0][name].model
    @$.pop   = args[0][name].pop
    @$export 'submit',
             'cancel'
    @_register()
  pop:(data)=>
    @$.pop(true)
    switch @_action
      when 'edit'
        if @can_pull('edit')
          @Api[@_controller].edit data.model, @attrs()
  cancel:=>
    @$.pop(false)
  submit:(e)=>
    $stop e
    if @$.model.id()
      @Api[@_controller].update @$.model.id(), @params()
    else
      @Api[@_controller].create @params()
    return false
  edit_success:(data)=>
    console.log 'edit success', data
  success:(data)=>
    @$.pop(false)
  error:(data)=>
    @$.err = data
  can_pull:(name)=>
    if _.is_array @pull
      _.any @pull, (n)-> n is name
    else
      @pull
  _register:=>
    if @_action is 'form'
      @$on "#{@_controller}/new#pop" , @pop
      @$on "#{@_controller}/edit#pop", @pop
      @$on "#{@_controller}/form#pop", @pop
    else
      @$on "#{@_controller}/#{@_action}#pop", @pop
    path = @_controller
    switch @_action
      when 'new'
        @$on "#{path}/new"       , @new_success
        @$on "#{path}/create"    , @success
        @$on "#{path}/create#err", @err
      when 'edit'
        @$on "#{path}/update"    , @success
        @$on "#{path}/destroy"   , @success
        @$on "#{path}/update#err", @err
        @$on "#{path}/edit"      , @edit_success if @can_pull('edit')
      else
        @$on "#{path}/#{@_action}"        , @custom_success
        @$on "#{path}/#{@_action}#success", @success
        @$on "#{path}/#{@_action}#err"    , @err
    true


window.Popup = Popup
