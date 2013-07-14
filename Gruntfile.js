'use strict';

module.exports = function(grunt) {

  // Project configuration.
  grunt.initConfig({
    source: ['src/**/*.coffee', 'test/**/*.coffee'],
    jshint: {
      options: {
        jshintrc: '.jshintrc'
      },
      gruntfile: {
        src: 'Gruntfile.js'
      },
      lib: {
        src: ['lib/**/*.js']
      }
    },
    nodeunit: {
      all: ['test/**/*_test.js']
    },
    coffee: {
      compile: {
        files: {
          'lib/viff.js': 'src/viff.coffee',
          'lib/comparison.js': 'src/comparison.coffee',
          'lib/index.js': 'src/index.coffee',
          'lib/reporter.js': 'src/reporter.coffee',
          'lib/html.report.template.js': 'src/html.report.template.coffee',
          'lib/process.argv.js': 'src/process.argv.coffee',
          'test/build/comparison_test.js': 'test/src/comparison_test.coffee',
          'test/build/viff_test.js': 'test/src/viff_test.coffee',
          'test/build/reporter_test.js': 'test/src/reporter_test.coffee',
          'test/build/process_argv_test.js': 'test/src/process_argv_test.coffee'
        }
      }
    },
    watch: {
      gruntfile: {
        files: '<%= jshint.gruntfile.src %>',
        tasks: ['jshint:gruntfile']
      },
      coffee: {
        files: '<%= source %>',
        tasks: ['coffee']
      },
      nodeunit: {
        files: '<%= source %>',
        tasks: ['coffee', 'nodeunit']
      },
      lib: {
        files: '<%= jshint.lib.src %>',
        tasks: ['jshint:lib']
      }
    },
  });

  // These plugins provide necessary tasks.
  grunt.loadNpmTasks('grunt-contrib-jshint');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-nodeunit');

  // Default task.
  grunt.registerTask('default', ['coffee', 'nodeunit']);

};
