parameter_name = (root)->
  name = root[0]
  name += '['  + root.slice(1).join('][') + ']' if root.length > 1
  name

if typeof File is 'undefined'
  class window.File
    constructor:->

has_attached_file = (value)->
  result = false
  if typeof value is 'object' && !(value instanceof File)
    for own k,v of value
      result |= has_attached_file v
  else if typeof value is 'array'
    for vv in v
      result |= has_attached_file vv
  else
    result |= value instanceof File
  return result

form_object_to_form_data = (value,fd=null,root=[]) ->
  fd = new FormData() unless fd
  if typeof value is 'object' && !(value instanceof File)
    for own k,v of value
      form_object_to_form_data v, fd, root.concat [k]
  else if typeof value is 'array'
    for i,vv in value
      form_object_to_form_data vv, fd, root.concat [i]
  else
    fd.append parameter_name(root), value
  fd

# AB - the headers isn't even getting passed through,
# this solution will not do
request_wrap = (method)=>
  #success and error callbacks can be set via returned promise
  (url, data, iso_path)=>
    ApiBase._request iso_path, method, url, undefined, data, undefined, undefined

class ApiBase
  @preload = (typeof _isomorphic != 'undefined')

  get    : request_wrap 'GET'
  post   : request_wrap 'POST'
  put    : request_wrap 'PUT'
  delete : request_wrap 'DELETE'

  @_request: (iso_path, method, url, headers, data, opts={})=>
    success = opts.success
    error   = opts.error
    extract = opts.extract
    attrs   = opts.attrs

    deferred = m.deferred()
    iso_pathless = (iso_path == undefined)

    config = (xhr)=>
      for k, v of headers
        vv = v
        vv = v() if typeof v is 'function'
        xhr.setRequestHeader k, vv
      xhr

    ev_success = (data)->
      $broadcast iso_path, data, attrs unless iso_pathless
      success(data,attrs) if typeof success is 'function'
      deferred.resolve data
    ev_error = (data)->
      $broadcast "#{iso_path}#err", data, attrs unless iso_pathless
      error(data,attrs) if typeof error is 'function'
      deferred.reject 'api_error'

    if(@preload && !iso_pathless)
      data = _iso_preload[iso_path]
      ev_success(data)
      ->
        data
    else
      console.log 'haf0', data
      if has_attached_file(data)
        form_data = form_object_to_form_data(data)
        serialize = (value)->
          return value
        attrs =
          method    : method
          url       : url
          data      : form_data
          serialize : serialize
          config    : config
        m.request(attrs).then(ev_success,ev_error)
      else
        attrs =
          method : method
          url    : url
          data   : data
          config : config
        attrs.extract = extract if extract
        m.request(attrs).then(ev_success,ev_error)

    deferred.promise
  _extract_id:(model)=>
    if typeof model is 'string' || typeof model is 'number'
      model
    else
      if typeof model.id is 'function'
        model.id()
      else
        model.id
  path:(args...)=>
    namespace = @namespace
    if(args[0] instanceof Array)
      path = args[0]
      if(args[1])
        namespace = args[1]
    else
      path = args
    path.unshift namespace if namespace
    path = path.join '/'
    "/#{path}"
  _resource:(tn,options)=>
    ns = options.namespace
    only = {index: true, new: true, create: true, show: true, edit: true, update: true, destroy: true}
    if typeof options is 'string' 
      only = {index: false, new: false, create: false, show: false, edit: false, update: false, destroy: false}
      only[o] = true for o in options.split(' ')
    @[tn] = {}
    @[tn].index   = (pms,opts)=>       ApiBase._request "#{tn}/index"  , 'GET'   , @path([tn], ns)                           , @headers, pms, opts if only.index
    @[tn].new     = (pms,opts)=>       ApiBase._request "#{tn}/new"    , 'GET'   , @path([tn,'new'], ns)                     , @headers, pms, opts if only.new
    @[tn].create  = (pms,opts)=>       ApiBase._request "#{tn}/create" , 'POST'  , @path([tn], ns)                           , @headers, pms, opts if only.create
    @[tn].show    = (model,pms,opts)=> ApiBase._request "#{tn}/show"   , 'GET'   , @path([tn,@_extract_id(model)], ns)       , @headers, pms, opts if only.show
    @[tn].edit    = (model,pms,opts)=> ApiBase._request "#{tn}/edit"   , 'GET'   , @path([tn,@_extract_id(model),'edit'], ns), @headers, pms, opts if only.edit
    @[tn].update  = (model,pms,opts)=> ApiBase._request "#{tn}/update" , 'PUT'   , @path([tn,@_extract_id(model)], ns)       , @headers, pms, opts if only.update
    @[tn].destroy = (model,pms,opts)=> ApiBase._request "#{tn}/destroy", 'DELETE', @path([tn,@_extract_id(model)], ns)       , @headers, pms, opts if only.destroy
    @_collection tn,action,method,ns for action,method of options.collection
    @_member     tn,action,method,ns for action,method of options.member
  _collection:(tn,a,method,ns)=>
    @[tn][a] = (params,opts)=> ApiBase._request "#{tn}/#{a}", method.toUpperCase(), @path([tn, a], ns), @headers, params, opts
  _member:(tn,a,method,ns)=>
    @[tn][a] = (model,params,opts)=> ApiBase._request "#{tn}/#{a}", method.toUpperCase(), @path([tn, model.id, a], ns),  @headers, params, opts
  constructor:()->
    @_resource table_name, options for table_name,options of @resources
window.ApiBase = ApiBase
