correct_config = {
  seleniumHost: 'http://localhost:4000/wd/hub',
  browsers: ['safari', 'firefox'],
  paths: ['/strict-mode'],
  envHosts: {
    custom: 'http://localhost:4000',
    custom2: 'http://localhost:4001'
  },
  reportFormat: 'json'
}

module.exports = correct_config