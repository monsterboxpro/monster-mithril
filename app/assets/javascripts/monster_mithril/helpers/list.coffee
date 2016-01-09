class List
  pull    : false
  popups  : false
  paginate: false
  search  : false
  action  : 'index'
  attrs: => {}
  constructor:->
    @collection = []
    @table_name = @_controller unless @table_name
    @_register()
    if typeof(@popups) is 'object'
      @$.pop = {}
      for name in @popups
        switch name
          when 'new'  then @$.pop.new  = @pop_new
          when 'edit' then @$.pop.edit = @pop_edit
          when 'show' then @$.pop.show = @pop_show
          else
            @$.pop[name] = @pop_custom(name)
    else if @popups is true
      name = @collection_name || @table_name
      @$.pop =
        new:  @pop_new
        show: @pop_show
        edit: @pop_edit
    if @paginate
      @$.paginate =
        page: $watch m.prop(parseInt(@param('page')) || 1), @reindex
    @reindex() if @pull
    #@$.$watch 'search', _.debounce(@update_search, 500) if @search
    @index_success null, @data() if @data
    @$export 'sort',
             'destroy'
    @$.loading = true
    @$.predicate =
      name: 'id'
      dir: 'asc'
  pop_new:=>
    n = "#{@table_name}_form"
    @_check_model n
    @$[n].model.reset()
    $broadcast "#{@table_name}/new#pop"
  pop_show:(model)=>
    n = "#{@_controller}_show"
    @_check_model n
    @$[n].model.reset()
    $broadcast "#{@table_name}/show#pop", model: model
  pop_edit:(model)=>
    n = "#{@table_name}_form"
    @_check_model n
    @$[n].model.reset()
    $broadcast "#{@table_name}/edit#pop", model: model
  pop_custom:(name)=>
    (model)=>
      n = "#{@table_name}_#{name}"
      @_check_model n
      @$[n].model.reset()
      $broadcast "#{@table_name}/#{name}#pop", model: model
  _check_model:(name)=>
    ctrl = "#{@_controller}/#{@_action}"
    unless @$[name]
      console.log "[List][#{ctrl}] @$", @$
      throw "[List][#{ctrl}] pop action expects #{name} to defined on scope"
    unless @$[name].model
      console.log "[List][#{ctrl}] @$.#{name}", @$[name]
      throw "[List][#{ctrl}] pop action expects a model for #{name} to defined on scope" 
  sort:(name)=>
    dir = if @$.predicate.name is name
      if @$.predicate.dir is 'desc' then 'asc' else 'desc'
    else
      'asc'
    @$.predicate = {name: name, dir: dir}
    @$location.search 'sort', "#{name},#{dir}"
    @$.sortable = true
    @reindex()
  update_search:(val,old)=>
    if old != val
      if @search is 'location'
        if val != ''
          @$location.search 'search', val
        else
          @$location.search 'search', null
      if @$.paginate
        @$.paginate.page 1
        @$location.search 'page', null
      @reindex() if @pull
  reindex:=>
    attrs = @attrs()
    attrs.page   = @$.paginate.page()       if @$.paginate && @$.paginate.page
    attrs.search = @$.search                if @search && @$.search
    attrs.sort   = @$location.search().sort if @$.sortable
    @$.loading = true
    @Api[@table_name][@action] attrs
  destroy:(model)=>
    name = _.singularize @table_name
    msg  = "Are you sure you wish to destroy this #{name}"
    @Api[@table_name].destroy model, @attrs() if confirm msg
  index_success:(data)=>
    @$.loading = false
    #paginate = headers('X-Pagination')
    #if paginate
      #@$.paginate = JSON.parse(paginate)
    name = @collection_name || @table_name
    @$[name] = data
    @collection = @$[name]
  create_success:(data)=>  _.create  @collection, data
  update_success:(data)=>  _.update  @collection, data
  destroy_success:(data)=> _.destroy @collection, data
  _register:=>
    path = @table_name
    path = [@_prefix(),name].join '/'  if _.any @scope
    @$on "#{path}/#{@action}", @index_success

    name = @collection_name || @table_name
    path = name
    path = [@_prefix(),name].join '/'  if _.any @scope

    @$on "#{path}/create" , @create_success
    @$on "#{path}/update" , @update_success
    @$on "#{path}/destroy", @destroy_success
    #if @pull
      #@$.$watch 'paginate.page', (new_val,old_val)=>
        #@reindex() if old_val != undefined && new_val != old_val
  _prefix:=>
    path = _.map @scope, (s)=> "#{_.pluralize(s)}/#{@$[s].id}"
    path.join '/'

window.List = List
