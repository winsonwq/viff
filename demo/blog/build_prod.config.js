'use strict'

module.exports = {
    seleniumHost: 'http://localhost:4444/wd/hub',
    browsers: ['firefox'],
    envHosts: {
      build: 'http://suncorpbank.com.au',
      prod: 'http://suncorpbank.com.au'
    },
    paths: require('./links.js'),
    reportFormat: 'html'
};