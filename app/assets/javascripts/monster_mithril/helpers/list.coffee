#
# $controller 'projects/index', class extends List
# reindex: Api.projects.index
# events: 'projects/index', 'projects/create'
#
#
# $controller 'projects/users', class extends List'
# reindex: Api.projects.users
# events: 'projects/users', 'users/create'
#


class List
  pull    : false
  popups  : false
  paginate: false
  search  : false
  controller: null
  attrs: => {}
  constructor:->
    @collection = []
    @controller ||= @_controller
    @action     ||= @_action
    unless @table_name
      @table_name =
      if @_action is 'index'
        @_controller
      else
        @_action
    @_register()
    @set_pop()
    @reindex() if @pull
    @index_success null, @data() if @data
    @$export 'destroy'
    @$.loading = true
  set_pop:=>
    @$.pop = {}
    if typeof(@popups) is 'object'
      for name in @popups
        @$pop "#{@_controller}/#{name}"
    else if @popups is true
      @$pop "#{@_controller}/form"

    dreindex = debounce @reindex, 100
    @check_paginate dreindex
    @check_sortable dreindex
    @check_search   dreindex

  check_paginate:(dreindex)=>
    return unless @paginate
    page = parseInt @param('page')
    @$.paginate =
      page: $watch m.prop(page ||  1), dreindex
  check_sortable:(dreindex)=>
    return unless @sortable
    val = @sortable.split(',')
    #@$.sort =
      #name: $watch m.prop(@param('sort') || val[0]), dreindex
      #by:   $watch m.prop(@param('by')   || val[1]), dreindex
    @$.sort =
      name: m.prop(@param('sort') || val[0])
      by:   m.prop(@param('by')   || val[1])
  check_search:(dreindex)=>
    return unless @search
    @$.search = $watch m.prop(@param('q')  || ''), dreindex
  reindex:=>
    attrs = @attrs()
    attrs.page   = @$.paginate.page() if @paginate && @$.paginate && @$.paginate.page
    attrs.search = @$.search()        if @search   && @$.search
    attrs.sort   = "#{@$.sort.name()},#{@$.sort.by()}" if @sortable && @$.sort
    @Api[@controller][@action] attrs, extract: @headers
  headers:(xhr)=>
    xhr.responseText
  destroy:(model,opts={})=>
    =>
      name = @table_name.singularize()
      msg  = "Are you sure you wish to destroy this #{name}"
      if confirm msg
        @Api[@controller].destroy model, @attrs() 
        if opts.now
          _.destroy @collection, model
  index_success:(data)=>
    @$.loading = false
    name = @collection_name || @table_name
    @$[name] = data
    @collection = @$[name]
  create_success:(data)=>  _.create  @collection, data
  update_success:(data)=>  _.update  @collection, data
  destroy_success:(data)=> _.destroy @collection, data
  _register:=>
    path = @controller
    @$on "#{path}/#{@action}", @index_success

    name = @collection_name || @table_name
    path = name

    @$on "#{path}/destroy", @destroy_success

window.List = List
