'use strict';

module.exports = function(grunt) {

  // Project configuration.
  grunt.initConfig({
    source: ['src/**/*.coffee', 'test/**/*.coffee'],
    nodeunit: {
      all: ['test/**/*_test.js']
    },
    coffee: {
      compile: {
        files: {
          'lib/viff.js': 'src/viff.coffee',
          'lib/comparison.js': 'src/comparison.coffee',
          'lib/index.js': 'src/index.coffee',
          'lib/color.helper.js': 'src/color.helper.coffee',
          'lib/process.argv.js': 'src/process.argv.coffee',
          'lib/image.generator.js': 'src/image.generator.coffee',
          'lib/console.status.js': 'src/console.status.coffee',
          'lib/case.js': 'src/case.coffee',
          'test/build/comparison_test.js': 'test/src/comparison_test.coffee',
          'test/build/viff_test.js': 'test/src/viff_test.coffee',
          'test/build/process_argv_test.js': 'test/src/process_argv_test.coffee',
          'test/build/image_generator_test.js': 'test/src/image_generator_test.coffee',
          'test/build/case_test.js': 'test/src/case_test.coffee'
        }
      }
    },
    watch: {
      coffee: {
        files: '<%= source %>',
        tasks: ['coffee']
      },
      nodeunit: {
        files: '<%= source %>',
        tasks: ['coffee', 'nodeunit']
      }
    },
  });

  // These plugins provide necessary tasks.
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-nodeunit');

  // Default task.
  grunt.registerTask('default', ['coffee', 'nodeunit']);

};
