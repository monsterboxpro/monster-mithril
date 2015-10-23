MonsterMithril
====================

Getting Started
--------------------

### Configure your application.coffee
In your application.coffee

    #=require      'monster-mithril'
    #=require_tree './controllers'
    #=require_tree './services'
    #=require_tree './filters'

### Create your Api Endpoints (services/api.coffee)

    $service 'Api', class extends ApiBase
      namespace: 'api'
      projects; {}
      tasks; 'create destroy'
      users:
        member:
          entry: 'post'
        collection:
          activity: 'get'

The Api service is auto injected into all $controllers
so you need to have an Api service defined

#### Makes it easy to call these routes:

    model = {id: 1}
    id    = 5
    data  = { key: 'value' }
    @Api.projects.index()       # GET   /api/projects
    @Api.users.show(model)      # GET   /api/users/1
    @Api.users.entry(id,attrs)  # POST  /api/users/5/entry  {key: 'value'}
    @Api.users.activity()       # GET   /api/users/activity

### MithrilJs Helpers (monster.coffee)

    $controller
    $view
    $comp
    $service
    $filter

#### Controllers

    $controller 'projects/index', class extends Index
      constructor:->
        @$ =
          data: @Api.tasks.index()

#### Views

    $view 'projects/index', class
      els = []
      for project in @$.data().projects
        els.push m '.project', project.name
      m 'projects', els

#### Services

    $service 'Map', class

#### Filters

    $filter 'highlight', (val)->
      # place code here

    $filter 'date_formate', (val)->
      # place code here

### Javascript Classes

Javascript classes that make common life easier.

* List  - Handle lists eg. indexes
* Show  - Handles show eg. indiviual members
* Popup - Handles popups
* Form  - Handles forms

TODO
--------------------
* Auto inject $f helper method into $controller and $view
* Fix issue with pas
* Fix issues with $comp to use m.component instead of what its doing
* Implement Javascript classes
