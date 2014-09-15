var gulp = require('gulp');
var gutil = require('gulp-util');
var coffee = require('gulp-coffee');
var sourcemaps = require('gulp-sourcemaps');
var mocha = require('gulp-mocha');
var run = require('run-sequence');
var _ = require('lodash');

var paths = {
  coffee: ['./src/*.coffee'],
  coffeeTest: ['./test/src/*.coffee'],
  scripts: ['./lib/*.js'],
  test: [
    'test/build/*.spec.js',
    'test/build/*_test.js'
  ]
};

// Not all tasks need to use streams
// A gulpfile is just another node program and you can use all packages available on npm
gulp.task('clean', function(cb) {
  // You can use multiple globbing patterns as you would with `gulp.src`
  del(['js'], cb);
});

// Runing mocha test cases
gulp.task('coffeeTest', function(cb) {
  return gulp.src(paths.coffeeTest)
      .pipe(coffee({bare: true}).on('error', gutil.log))
      .pipe(gulp.dest('test/build'))
});

// Runing mocha test cases
gulp.task('coffee', function(cb) {
  return gulp.src(paths.coffee)
      .pipe(coffee({bare: true}).on('error', gutil.log))
      .pipe(gulp.dest('lib'))
});

gulp.task('build', ['coffee', 'coffeeTest'])

// Runing mocha test cases
gulp.task('test', ['coffee', 'coffeeTest'], function(cb) {
  return gulp.src(paths.test)
      .pipe(mocha({
        timeout: 10000,
        reporter: 'nyan'
      }));
});

// Rerun the task when a file changes
gulp.task('watch', function() {
  gulp.watch(_.contact(paths.coffeeTest, paths.coffee), ['test']);
});

gulp.task('default', ['test']);