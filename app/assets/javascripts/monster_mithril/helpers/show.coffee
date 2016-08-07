class Show
  pull   : false
  popups : false
  action : 'show'
  collection_name: null
  attrs: => {}
  constructor:->
    @table_name = @_controller unless @table_name
    @_register()
    @reindex() if @pull
    if typeof(@popups) is 'object'
      @$.pop = {}
      for name in @popups
        @$.pop[name] = @pop_custom(name)
    else if @popups is true
      name = @collection_name || @table_name
      @$.pop =
        edit: @pop_edit
    @$.destroy = @destroy
  pop_new:=>
    @$["#{@table_name}_form"].model.reset()
    $broadcast "#{@table_name}/new#pop"
  pop_edit:(model)=>
    =>
      @$["#{@table_name}_form"].model.reset id: @param('id')
      $broadcast "#{@table_name}/edit#pop", model: model
  pop_custom:(name)=>
    (model)=>
      @$["#{@table_name}_#{name}"].model.reset id: @param('id')
      $broadcast "#{@table_name}/#{name}#pop", model: model
  _register:=>
    path = @table_name
    @$on "#{path}/show"   , @show_success
    @$on "#{path}/update" , @update_success
    @$on "#{path}/destroy", @destroy_success
  show_success:(data)=>
    @$.model = data
  update_success:(data)=>
    @$.model = data
  destroy_success:=>
  reindex:=>
    attrs = @attrs()
    @Api[@table_name][@action] {id: @param('id')}, attrs
  _prefix:=>
    path = _.map @scope, (s)=> "#{_.pluralize(s)}/#{@$[s].id}"
    path.join '/'
  destroy:(model)=>
    =>
      name = @table_name.singularize()
      msg  = "Are you sure you wish to destroy this #{name}"
      @Api[@table_name].destroy model, @attrs() if confirm msg

window.Show = Show
