MonsterMithril
====================

Getting Started
--------------------

### Configure your application.coffee
In your application.coffee
```coffee
#=require      'monster-mithril'
#=require_tree './controllers'
#=require_tree './services'
#=require_tree './filters'
```

### Create your Api Endpoints (services/api.coffee)
```coffee
$service 'Api', class extends ApiBase
  namespace: 'api'
  resources
    projects; {}
    tasks; 'create destroy'
    users:
      member:
        entry: 'post'
      collection:
        activity: 'get'
```
The Api service is auto injected into all $controllers
so you need to have an Api service defined

```coffee
@Api = new Api()
```

#### Makes it easy to call these routes:

```coffee
model = {id: 1}
id    = 5
data  = { key: 'value' }
@Api.projects.index()       # GET   /api/projects
@Api.users.show(model)      # GET   /api/users/1
@Api.users.entry(id,attrs)  # POST  /api/users/5/entry  {key: 'value'}
@Api.users.activity()       # GET   /api/users/activity
```

### MithrilJs Helpers (monster.coffee)

    $controller
    $view
    $comp
    $service
    $filter

#### Controllers

```coffee
$controller 'projects/index', class extends Index
  constructor:->
    @$ =
      tasks: []
      data: @Api.tasks.index({},@success)
  success:(data)=>
    @$.tasks = data.tasks
    data
```
#### Views
```coffee
$view 'projects/index', class
  render:=>
    els = []
    for project in @$.data().projects
      els.push m '.project', project.name
    m 'projects', els
```

#### Layouts
  You can define layouts views in views/layouts/<layout file>.coffee
  and use the $layout helper.

```coffee
$view 'projects/index', class
  render:=>
    m '.content', 'this is my content
    $layout @$, content, layout: 'homepage'
```

#### Services
```coffee
$service 'Map', class
```

#### Filters
```coffee
$filter 'highlight', (val)->
  # place code here

$filter 'date_formate', (val)->
  # place code here
```

### Javascript Classes

Javascript classes that make common life easier.

* List  - Handles lists eg. indexes
* Show  - Handles show eg. indiviual members
* Popup - Handles popups
* Form  - Handles forms


#### List
```coffee
$controller 'entries/index', class extends List
  pull: true
```

pull by default is treu, and will trigger: @Api.entries.index()

Events that are being followed:

```coffee
@$on entries/index  , @index_success
@$on entries/update , @update_success
@$on entries/create , @create_success
@$on entries/destroy, @destroy_success
```

#### Show
    $controller 'entries/show' class extends Show

entries/index
entries/update
entries/create

#### Popup
    $controller 'entries/form' class extends Popup
      pull: ['','edit']

pull
attrs - for pull
params - for saving
events
pop

#### Form
```coffee
$controller 'entries/new' class extends Form
```
```coffee
$controller 'entries/edit' class extends Form
  pull: true
```
```coffee
$controller 'entries/form' class extends Form
  pull: ['edit']
```

TODO
--------------------
* Fix issue with passing argumetns to controllers
* Fix issues with $comp to use m.component instead of what its doing
* Implement Javascript classes
