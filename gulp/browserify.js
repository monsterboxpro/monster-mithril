var gulp = require('gulp');
var foreach = require("gulp-foreach");
var coffee = require('gulp-coffee');

var path = require('path');
var extend = require("node.extend");
var source = require('vinyl-source-stream');

var watchify = require('watchify');
var browserify = require('browserify');
var coffeeify = require('coffeeify');

var request = require('request');
var q = require('q');

//Detect production/development environment from system environment vars.
//Defaults to 'development'.
var environment = process.env.NODE_ENV || "production";

var dependencies = [
    'underscore',
    'mithril'
];

var make_bundle = function(opts){
    
    if(opts === undefined){
        opts = {};
    }
    
    if(opts.use_watchify === undefined){
        opts.use_watchify = (environment == "development");
    }
    
    if(opts.bsfy_opts === undefined){
        opts.bsfy_opts = {};
    }
    
    if(opts.bsfy_bower_opts === undefined){
        opts.bsfy_bower_opts = {};
    }
    
    var out_file = opts.out_file || path.basename(opts.bsfy_opts.entries);
        
    var bsfy_opts_common = {
        debug: true,
        paths: ["app/assets/javascripts/monster_mithril"],
        extensions: ['.coffee'],
        cache: {},
        packageCache: {}
    };
    
    var bsfy_opts = extend(bsfy_opts_common, opts.bsfy_opts);

    var b = browserify(bsfy_opts);
    
    if(opts.use_watchify){
        b = watchify(b);
        b.on('update', rebundle);
    }

    b.transform(coffeeify, {
        bare: true,
        header: true
    });
    
    b.plugin("browserify-bower", opts.bsfy_bower_opts);

    function rebundle () {
        console.log("Bundling "+out_file+"...");
        return b.bundle()
            .pipe(source(out_file))
            .pipe(gulp.dest('app/dist')); 
    }

    return rebundle();

};

gulp.task("bsfy-scripts", function(){
    return make_bundle({
        out_file: "monster-mithril-all.js",
        bsfy_opts: {entries: "app/assets/javascripts/monster-mithril.js"}
    }).on('end', function(){
      return make_bundle({
          out_file: "monster-mithril-standalone.js",
          bsfy_opts: {entries: "app/assets/javascripts/monster-mithril.js"},
          bsfy_bower_opts: {external: dependencies}
      });
    });
});