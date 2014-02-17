'use strict';

module.exports = (grunt) -> 

  # Project configuration.
  grunt.initConfig

    source: ['src/**/*.coffee', 'test/**/*.coffee', 'gruntfile.coffee'],

    nodeunit: 
      all: ['test/**/*_test.js']

    coffee: 
      compile: 
        files: 
          'lib/viff.js': 'src/viff.coffee',
          'lib/comparison.js': 'src/comparison.coffee',
          'lib/index.js': 'src/index.coffee',
          'lib/color.helper.js': 'src/color.helper.coffee',
          'lib/process.argv.js': 'src/process.argv.coffee',
          'lib/image.generator.js': 'src/image.generator.coffee',
          'lib/console.status.js': 'src/console.status.coffee',
          'lib/testcase.js': 'src/testcase.coffee',
          'lib/capability.js': 'src/capability.coffee',
          'test/build/comparison_test.js': 'test/src/comparison_test.coffee',
          'test/build/viff_test.js': 'test/src/viff_test.coffee',
          'test/build/process_argv_test.js': 'test/src/process_argv_test.coffee',
          'test/build/image_generator_test.js': 'test/src/image_generator_test.coffee',
          'test/build/testcase_test.js': 'test/src/testcase_test.coffee',
          'test/build/capability_test.js': 'test/src/capability_test.coffee'

    watch:
      coffee:
        files: '<%= source %>'
        tasks: ['coffee']
      nodeunit: 
        files: '<%= source %>'
        tasks: ['default']

    mochaTest:
      test:
        options:
          reporter: 'spec'
        src: ['test/**/*.js']

  # These plugins provide necessary tasks.
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-nodeunit');
  grunt.loadNpmTasks('grunt-mocha-test');

  # Default task.
  grunt.registerTask('default', ['coffee', 'nodeunit', 'mochaTest']);
