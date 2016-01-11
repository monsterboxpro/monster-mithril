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
    dreindex = debounce @reindex, 100
    if @paginate
      page = parseInt @param('page')
      @$.paginate =
        page: $watch m.prop(page ||  1), dreindex
    if @sortable
      val = @sortable.split(',')
      @$.sort =
        name: $watch m.prop(@param('sort') || val[0]), dreindex
        by:   $watch m.prop(@param('by')   || val[1]), dreindex
    if @search
      @$.search = $watch m.prop(@param('q')  || ''), dreindex
    @reindex() if @pull
    @index_success null, @data() if @data
    @$export 'destroy'
    @$.loading = true
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
    attrs.page   = @$.paginate.page() if @paginate && @$.paginate && @$.paginate.page
    attrs.search = @$.search()        if @search   && @$.search
    attrs.sort   = "#{@$.sort.name()},#{@$.sort.by()}" if @sortable && @$.sort
    @$.loading = true
    @Api[@table_name][@action] attrs
  destroy:(model,opts={})=>
    name = @table_name.singularize()
    msg  = "Are you sure you wish to destroy this #{name}"
    @Api[@table_name].destroy model, @attrs() if confirm msg
    if opts.now
      _.destroy @collection, model
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
    @$on "#{path}/#{@action}", @index_success

    name = @collection_name || @table_name
    path = name

    @$on "#{path}/create" , @create_success
    @$on "#{path}/update" , @update_success
    @$on "#{path}/destroy", @destroy_success

window.List = List
