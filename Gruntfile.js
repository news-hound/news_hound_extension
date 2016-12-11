module.exports = function(grunt) {

  grunt.initConfig({
    coffeelint: {
      all: ['src/**/*.js.coffee']
    },
    coffee: {
      contentScript: {
        expand: true,
        flatten: false,
        cwd: 'src',
        src: "content-script.js.coffee",
        dest: 'build',
        ext: '.js'
      }
    },
    clean: {
      build: ['tmp', 'build/']
    },
    copy: {
      extension: {
        files: [
          {
            expand: true,
            cwd: 'static',
            src: '**/*',
            dest: 'build/'
          },
          {
            expand: true,
            cwd: 'bower_components',
            src: '**/*',
            dest: 'build/'
          }
        ]
      }
    },
    sass: {
      options: {
        sourceMap: false
      },
      dist: {
        files: [
          {
            'build/content-script.css': 'src/content-script.sass'
          },
          {
            'build/popup.css': 'src/popup.sass'
          }
        ]
      }
    },
    clean: {
      build: ['tmp', 'build']
    },
    watch: {
      build: {
        files: ['src/**/*.js.coffee', 'spec/**/*.js.coffee'],
        tasks: ['coffee']
      },
      concat: {
        files: [
          'bower_components/**/*.css',
          'bower_components/**/*.js',
          'tmp/*.js'
        ],
        tasks: ['concat']
      },
      sass: {
        files: [
          'src/**/*.sass'
        ],
        tasks: ['sass']
      },
      copy: {
        files: [
          'static/*',
        ],
        tasks: ['copy']
      }
    }
  });

  grunt.loadNpmTasks('grunt-coffeelint');
  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-sass');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-concat');
  grunt.loadNpmTasks('grunt-contrib-clean');
  grunt.loadNpmTasks('grunt-contrib-copy');

  grunt.registerTask('build', ['coffee', 'concat', 'sass', 'copy']);
  grunt.registerTask('debug', ['clean', 'build', 'watch'])
  grunt.registerTask('default', ['build']);
};
