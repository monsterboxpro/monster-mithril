# $controller 'users/show', class extends Popup
#   pull: true
#
# $controller 'users/form', class extends Popup
#   pull: ['edit']
#
# $controller 'users/show', class extends Popup
#   attrs:=>
#     { student_id: @$stateParams.id }
#
# $controller 'users/form', class extends Popup
#   title:
#     new: 'Add a user'
#     edit: 'Update a user'

# $controller 'users/form', class extends Popup
#   save_label:
#     new: 'Add'
#     edit: 'Update User'
#

class Popup
  pull: false
  blank: false
  clear: true
  params:=>
    attrs = {}
    attrs[@_controller.singularize()] = @$.model.params()
    attrs
  attrs:=> {}
  constructor:(args)->
    name = "#{@_controller}_#{@_action}"
    @$.popup_class = "#{name}_popup"
    @set_args args, name
    @$.data = null
    @$export 'submit',
             'cancel'
    @_register()
  set_args:(args,name)=>
    lbl = "[Popup][#{@_controller}/#{@_action}] expected"
    throw "#{lbl} #{name} for args" unless args[0][name]
    @$[key] = val for key,val of args[0][name]
  validate:=>
    lbl = "[Popup][#{@_controller}/#{@_action}] expects "
    throw "#{lbl} model" unless @$.model
    throw "#{lbl} pop"   unless @$.pop
    throw "#{lbl} title" unless @$.title
  pop:(data={})=>
    @validate()
    @$.model.errors {}
    @$.pop(true)
    @reindex(data.model)
  reindex:(data)=>
    if data
      model = data
      id    = data.id
    else
      model = @$.model
      id    = @$.model.id()
    api = @Api[@_controller]
    a   = @_action
    if      @can_pull('edit') && a is 'edit'       then api.edit {id: id}, @attrs()
    else if @can_pull('edit') && a is 'form' && id then api.edit {id: id}, @attrs()
    else if @can_pull('new')  && a is 'form'       then api.new @attrs()
    else if @can_pull()                            then api[@_action] {id: id}, @attrs()
    @set_title {id: id}
  set_title:(data)=>
    title =
    if @_action is 'form'
      if data.id
        if @title && @title.edit
           @title.edit()
        else
          "Edit #{@_controller.singularize()}".titleize()
      else
        if @title && @title.new
          @title.new()
        else
          "New #{@_controller.singularize()}".titleize()
    else
      "#{@_action} #{@_controller.singularize()}".titleize()
    @$.title title
  cancel:=>
    @$.pop(false)
  submit:(e)=>
    $stop e
    if @_action isnt 'form' && @_action isnt 'new' && @_action isnt 'edit'
      @Api[@_controller][@_action] {id: @$.model.id()}, @params()
    else if @$.model && @$.model.id()
      @Api[@_controller].update @$.model.id(), @params()
    else
      @Api[@_controller].create @params()
    return false
  edit_success:(data)=>
    if @$.model
      @$.model.reset data
  custom_success:(data)=>
    if @$.model
      @$.model.reset data
  create_success:(data)=> @success data
  update_success:(data)=>  @success data
  destroy_success:(data)=> # define yourself
  success:(data)=>
    @$.pop(false)
  error:(data)=>
    @$.model.errors data
  can_pull:(name)=>
    if _.is_array @pull
      _.any @pull, (n)-> 
        n is name
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
        @$on "#{path}/create"    , @create_success
        @$on "#{path}/create#err", @error
      when 'edit'
        @$on "#{path}/update"    , @update_success
        @$on "#{path}/destroy"   , @destroy_success
        @$on "#{path}/update#err", @error
        @$on "#{path}/edit"      , @edit_success if @can_pull('edit')
      when 'form'
        @$on "#{path}/new"       , @new_success
        @$on "#{path}/create"    , @create_success
        @$on "#{path}/create#err", @error
        @$on "#{path}/update"    , @update_success
        @$on "#{path}/destroy"   , @destroy_success
        @$on "#{path}/update#err", @error
        @$on "#{path}/edit"      , @edit_success
      else
        @$on "#{path}/#{@_action}"        , @custom_success
        @$on "#{path}/#{@_action}#err"    , @error
        @$on "#{path}/update"             , @success
        @$on "#{path}/update#err"         , @error
    true


window.Popup = Popup
