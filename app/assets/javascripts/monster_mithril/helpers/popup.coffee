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
  params:=>
    attrs = {}
    attrs[@_controller.singularize()] = @$.model.params()
    attrs
  attrs:=> {}
  constructor:(args)->
    name = "#{@_controller}_#{@_action}"
    @$.popup_class = "#{name}_popup"
    unless args[0][name]
      console.log '[Popup] arguments:', args[0]
      throw "[Popup][#{@_controller}/#{@_action}] expected #{name} for args" 
    throw "[Popup][#{@_controller}/#{@_action}] expects model" unless args[0][name].model
    throw "[Popup][#{@_controller}/#{@_action}] expects pop"   unless args[0][name].pop
    throw "[Popup][#{@_controller}/#{@_action}] expects title" unless args[0][name].title
    @$[key] = val for key,val of args[0][name]
    @$.data = null
    @$export 'submit',
             'cancel'
    @_register()
  pop:(data)=>
    @$.pop(true)
    @$.title "#{@_action} #{@_controller.singularize()}".titleize()
    switch @_action
      when 'edit'
        if @can_pull('edit')
          @Api[@_controller].edit data.model, @attrs()
       when 'form'
         if data && data.model && data.model.id
           if @can_pull('edit')
             @Api[@_controller].edit data.model, @attrs()
           if @title && @title.edit
              @$.title @title.edit()
           else
             @$.title "Edit #{@_controller.singularize()}".titleize()
         else
           if @can_pull('new')
             @Api[@_controller].new @attrs()
           if @title && @title.new
            @$.title @title.new()
           else
             @$.title "New #{@_controller.singularize()}".titleize()
       else
         if @can_pull()
           @Api[@_controller][@_action] data.model, @attrs()

  cancel:=>
    @$.pop(false)
  submit:(e)=>
    $monster.$stop e
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
      for k,v of data
        @$.model[k](v) if @$.model[k]
  success:(data)=>
    @$.pop(false)
  error:(data)=>
    @$.err = data
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
        @$on "#{path}/create"    , @success
        @$on "#{path}/create#err", @error
      when 'edit'
        @$on "#{path}/update"    , @success
        @$on "#{path}/destroy"   , @success
        @$on "#{path}/update#err", @error
        @$on "#{path}/edit"      , @edit_success if @can_pull('edit')
      when 'form'
        @$on "#{path}/new"       , @new_success
        @$on "#{path}/create"    , @success
        @$on "#{path}/create#err", @error
        @$on "#{path}/update"    , @success
        @$on "#{path}/destroy"   , @success
        @$on "#{path}/update#err", @error
        @$on "#{path}/edit"      , @edit_success
      else
        @$on "#{path}/#{@_action}"        , @success
        @$on "#{path}/#{@_action}#err"    , @error
        @$on "#{path}/update"             , @success
        @$on "#{path}/update#err"         , @error
    true


module.exports = Popup
