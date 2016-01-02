'use strict';

//Require external deps
var _ = window._ = require("underscore");
var m = window.m = require("mithril");

window.ApiBase = require("core/api.coffee");
window.$comp = require("core/comp.coffee");
window.$controller = require("core/controller.coffee");
window.$layout = require("core/layout.coffee");
window.$model = require("core/model.coffee");
window.$popup = require("core/popup.coffee");
window.$service = require("core/service.coffee");
window.$view = require("core/view.coffee");

_.extend(window, require("core/dom.coffee"));
_.extend(window, require("core/events.coffee"));
_.extend(window, require("core/filter.coffee"));
