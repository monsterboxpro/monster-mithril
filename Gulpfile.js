var gulp = require("gulp");
var include = require("gulp-include");

require("./gulp/browserify.js");

gulp.task('default', ["bsfy-scripts"]);