class Form
  pull: false
  params:=>
    attrs = {}
    attrs["#{@table_name}".singularize()] = @$.model.params()
    attrs
  attrs:=> {}
  constructor:(args)->
    name = "#{@_controller}_#{@_action}"
    @table_name ||= @_controller
    @action     ||= @_action
    @action       = 'new'  if @_action is 'form'
    @action       = 'edit' if @_action is 'form' and @param('id')
    @$.loading = false
    if args[0]
      unless args[0][name]
        console.log '[Form] arguments:', args[0]
        throw "[Form][#{@_controller}/#{@_action}] expected #{name} for args" 
      throw "[Form][#{@_controller}/#{@_action}] expects model" unless args[0][name].model
      @$[key] = val for key,val of args[0][name]
    else
      @$.model = $monster.$model(@_controller.classify())
    @$export 'submit',
             'back',
             'destroy'
    @_register()
    @reindex()
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
    $monster.$stop e
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
  create_success:(e,data)=> @success data
  update_success:(e,data)=>  @success data
  destroy_success:(e,data)=> # define yourself
  success:(data)=> m.route "#{@table_name}/#{data.id}"
  error:(data)=>
    @$.err = data
  custom_success:(e,data)=>
    @$.model = data
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

module.exports = Form
