'use strict'

module.exports = {
    seleniumHost: 'http://localhost:4444/wd/hub',
    browsers: ['firefox', 'safari'],
    envHosts: {
      build: 'http://localhost:4000',
      prod: 'http://www.ishouldbeageek.me'
    },
    paths: require('./links.js'),
    reportFormat: 'html'
};