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

    @$.pop = {}
    if typeof(@popups) is 'object'
      for name in @popups
        @$pop "#{@_controller}/#{name}"
    else if @popups is true
      @$pop "#{@_controller}/form"

    @$.destroy = @destroy
  _register:=>
    path = @table_name
    @$on "#{path}/show"   , @show_success
    @$on "#{path}/destroy", @destroy_success
  show_success:(data)=>
    @$.model = data
  update_success:(data)=>
    @$.model = data
  destroy_success:=>
  reindex:=>
    attrs = @attrs()
    @Api[@table_name][@action] {id: @param('id')}, attrs, extract: @headers
  headers:(xhr)=>
    xhr.responseText
  _prefix:=>
    path = _.map @scope, (s)=> "#{_.pluralize(s)}/#{@$[s].id}"
    path.join '/'
  destroy:(model)=>
    =>
      name = @table_name.singularize()
      msg  = "Are you sure you wish to destroy this #{name}"
      @Api[@table_name].destroy model, @attrs() if confirm msg

window.Show = Show
