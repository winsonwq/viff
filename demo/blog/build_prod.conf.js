'use strict'

module.exports = function (webdriver){

  return {
    seleniumHost: 'http://localhost:4444/wd/hub',
    browsers: ['firefox', 'chrome'],
    envHosts: {
      build: 'http://localhost:4000',
      prod: 'http://www.ishouldbeageek.me'
    },
    paths: require('./links.js')(webdriver),
    reportFormat: 'html'
  }
};