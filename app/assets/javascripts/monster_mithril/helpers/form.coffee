class Form
  redirect: true
  pull: false
  params:=>
    attrs = {}
    attrs["#{@table_name}".singularize()] = @$.model.params()
    attrs
  attrs:=> {}
  constructor:(args)->
    @table_name ||= @_controller
    @action     ||= @_action
    @action       = 'new'  if @_action is 'form'
    @action       = 'edit' if @_action is 'form' and @param('id')
    @$.loading = false
    @set_model args
    if @redirect is false
      @$.flash = m.prop()
    @$export 'submit',
             'back',
             'destroy'
    @_register()
    @reindex()
  set_model:(args)=>
    name = "#{@_controller}_#{@_action}"
    if args[0]
      unless args[0][name]
        console.log '[Form] arguments:', args[0]
        throw "[Form][#{@_controller}/#{@_action}] expected #{name} for args" 
      throw "[Form][#{@_controller}/#{@_action}] expects model" unless args[0][name].model
      @$[key] = val for key,val of args[0][name]
    else
      @$.model = $model(@_controller.classify())
  reindex:=>
    switch @action
      when 'new'
        @Api[@table_name].new @attrs() if @can_pull('new')
      when 'edit'
        @Api[@table_name].edit @param('id'), @attrs() if @can_pull('edit')
      else
        if @can_pull()
          @Api[@table_name][@action] @param('id'), @attrs()
  submit:(e)=>
    $stop e
    params = @params()
    switch @action
      when 'new'  then @Api[@table_name].create             params
      when 'edit' then @Api[@table_name].update   @$.model, params
      else             @Api[@table_name][@action] @$.model, params
    return false
  _register:=>
    switch @action
      when 'edit'
        @$on "#{@table_name}/edit"      , @edit_success
        @$on "#{@table_name}/update"    , @update_success
        @$on "#{@table_name}/update#err", @error
        @$on "#{@table_name}/destroy"   , @destroy_success
      when 'new'
        @$on "#{@table_name}/new"       , @new_success
        @$on "#{@table_name}/create"    , @create_success
        @$on "#{@table_name}/create#err", @error
      else
        @$on "#{@table_name}/#{@action}"        , @custom_success
        @$on "#{@table_name}/#{@action}#success", @success
        @$on "#{@table_name}/#{@action}#err"    , @error
  new_success:(data)=>
    @$.model.reset data
    name = @table_name.singularize()
    @$.loading = true
  edit_success:(data)=>
    @$.model.reset data
    name         = @table_name.singularize()
    @$.loading = true
  create_success:(data)=> @success data
  update_success:(data)=>  @success data
  destroy_success:(data)=> # define yourself
  success:(data)=> 
    if @redirect is true
      m.route "#{@table_name}/#{data.id}"
    else if @redirect is false
      @$.flash 'success'
    else
      m.route @redirect()
  error:(data)=>
    @$.model.errors data
  custom_success:(data)=>
    @$.model.reset data
  can_pull:(name)=>
    if _.is_array @pull
      _.any @pull, (n)-> n is name
    else
      @pull
  back:=>
    switch @action
      when 'new'  then m.route "/#{@table_name}"
      when 'edit' then m.route "#{@table_name}/#{@param('id')}"
  destroy:=>
    name = @table_name.singularize()
    msg  = "Are you sure you wish to destroy this #{name}"
    @Api[@table_name].destroy @$.model, @attrs() if confirm msg

window.Form = Form
