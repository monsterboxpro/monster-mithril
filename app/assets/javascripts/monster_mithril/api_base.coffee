class ApiBase
  _get:(   tn,a,name,data={},success,error)=> @_request tn, a, 'GET'   , name, data, success, error
  _post:(  tn,a,name,data={},success,error)=> @_request tn, a, 'POST'  , name, data, success, error
  _put:(   tn,a,name,data={},success,error)=> @_request tn, a, 'PUT'   , name, data, success, error
  _delete:(tn,a,name,data={},success,error)=> @_request tn, a, 'DELETE', name, data, success, error
  _request:(tn,a,kind,url,data,success,error)=> 
    ev_success = (data)->
      $broadcast "#{tn}/#{a}", data
      success(data) if success
      data
    ev_error = (data)->
      $broadcast "#{tn}/#{a}#err", data
      error(data) if error
      data

    if @preload
      ->
        data = _iso_preload["#{tn}/#{a}"]
        success(data) if success
        data
    else
      m.request(method: kind, url: url, data: data, config: @_config).then(ev_success,error)
  _config:(xhr)=> xhr.setRequestHeader 'X-CSRF-Token',  $dom.get("meta[name='csrf-token']")[0].content
  _extract_id:(model)=>
    if typeof model is 'string' || typeof model is 'number'
      model
    else
      model.id
  path:(args...)=>
    path = []
    path.push @namespace if @namespace
    path.push a for a in args
    path = path.join '/'
    "/#{path}"
  _resource:(tn,options)=>
    only = {index: true, new: true, create: true, show: true, edit: true, update: true, destroy: true}
    if typeof options is 'string' 
      only = {index: false, new: false, create: false, show: false, edit: false, update: false, destroy: false}
      only[o] = true for o in options.split(' ')
    @[tn] = {}
    if only.index
      @[tn].index = (params,success,error)=> @_get tn, 'index', @path(tn), params, success,error
    if only.new
      @[tn].new = (params,success,error)=> @_get tn, 'new', @path(tn,'new'), params, success,error
    if only.create
      @[tn].create = (params,success,error)=> @_post tn, 'create', @path(tn), params, success,error
    if only.show
      @[tn].show = (model,params,success,error)=> @_get tn, 'show', @path(tn,@_extract_id(model)), params, success,error
    if only.edit
      @[tn].edit = (model,params,success,error)=> @_get tn, 'edit', @path(tn,@_extract_id(model),'edit'), params, success,error
    if only.update
      @[tn].update = (model,params,success,error)=> @_put tn, 'update', @path(tn,@_extract_id(model)), params, success,error
    if only.destroy
      @[tn].destroy = (model,params,success,error)=> @_delete tn, 'destroy', @path(tn,@_extract_id(model)), params, success,error
    @_collection tn,action,method for action,method of options.collection
    @_member     tn,action,method for action,method of options.member
  _collection:(tn,a,method)=>
    name = @path tn, a
    fun = switch method
      when 'get'     then (params,success,error)=> @_get     tn, a, name, params, success, error
      when 'post'    then (params,success,error)=> @_post    tn, a, name, params, success, error
      when 'put'     then (params,success,error)=> @_put     tn, a, name, params, success, error
      when 'destroy' then (params,success,error)=> @_delete  tn, a, name, params, success, error
    @[tn][a] = fun
  _member:(tn,a,method)=>
    fun = switch method
      when 'get'     then (model,params,success,error)=> @_get    tn, a, @path(tn, model.id, a), params, success, error
      when 'post'    then (model,params,success,error)=> @_post   tn, a, @path(tn, model.id, a), params, success, error
      when 'put'     then (model,params,success,error)=> @_put    tn, a, @path(tn, model.id, a), params, success, error
      when 'destroy' then (model,params,success,error)=> @_delete tn, a, @path(tn, model.id, a), params, success, error
    @[tn][a] = fun
  constructor:()->
    @preload =  typeof _isomorphic != 'undefined'
    @_resource table_name, options for table_name,options of @resources
window.ApiBase = ApiBase

