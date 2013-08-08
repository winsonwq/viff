'use strict'

module.exports = {
    seleniumHost: 'http://localhost:4444/wd/hub',
    browsers: ['firefox'],
    envHosts: {
      build: 'http://suncorpbank.com.au',
      prod: 'http://suncorpbank.com.au'
    },
    paths: [
      ['/', '.region.region-sidebar-second.sidebar'],
      ['/', '#block-menu-block-1'],
      ['/', '#columns'],
      ['/', '#page-footer'],
      '/savings',
      '/savings-accounts',
      '/savings/savings-accounts/help-me-choose',
      ['/savings/savings-accounts/help-me-choose', '.call-to-action'],
      ['/bank-accounts/personal-transactions/compare-accounts', '#main-content']
    ],
    reportFormat: 'file'
};