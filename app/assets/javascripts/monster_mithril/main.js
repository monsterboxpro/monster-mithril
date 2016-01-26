'use strict';

var window = window || {};

//Require external deps
var _ = window._ = require("underscore");
var m = window.m = require("mithril");

var $monster = {core: {}, helpers: {}};

var app = $monster.$app = require("./monster.coffee");

$monster.core.ApiBase = require("./core/api.coffee");

$monster.helpers.Popup = require("./helpers/popup.coffee");
$monster.helpers.Show = require("./helpers/show.coffee");
$monster.helpers.List = require("./helpers/list.coffee");
$monster.helpers.Form = require("./helpers/form.coffee");

$monster.$mixin = require("./core/mixin.coffee");
$monster.$location = require("./core/location.coffee");
$monster.$controller = require("./core/controller.coffee");
$monster.$layout = require("./core/layout.coffee");
$monster.$model = require("./core/model.coffee");
$monster.$popup = require("./core/popup.coffee");
$monster.$service = require("./core/service.coffee");
$monster.$view = require("./core/view.coffee");

_.extend($monster, require("./core/comp.coffee"));
_.extend($monster, require("./core/dom.coffee"));
_.extend($monster, require("./core/events.coffee"));
_.extend($monster, require("./core/filter.coffee"));

//Add all internal $monster keys to the global scope within this library so that internal
//components can reference things within the monster-mithril library without the namespace.
_.extend(this, $monster);

$monster._ = _;
$monster.m = m;

window.$monster = $monster;
module.exports = $monster;