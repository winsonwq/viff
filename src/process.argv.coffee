_ = require 'underscore'

parseBrowsers = (value) ->
  browsers = []
  for browser in value.split ','
    browser = browser.trim()
    browsers.push(browser) unless _.isEmpty browser

  browsers

parseEnvHosts = (value) ->
  envValues = value.split ','
  envHosts = {}
  for envHostStr in envValues
    unless _.isEmpty(envHostStr)
      [env, host]= envHostStr.trim().split '='
      envHosts[env] = host

  envHosts

parsePaths = (value) ->
  _.select value.split(','), (path) -> !_.isEmpty(path.trim())

mergeAndValidateConfig = (seleniumHost, browsers, envHosts, paths, reportFormat, config) ->
  c = config || {}
  
  for name, idx in ['seleniumHost', 'browsers', 'envHosts', 'paths', 'reportFormat']
    c[name] = arguments[idx] || c[name]

  c.browsers = ['firefox'] if c.browsers is undefined or c.browsers.length == 0
  c.reportFormat = 'html' if c.reportFormat is undefined
  
  throw new Error('--selenium-host isn\'t set correctly') if c.seleniumHost is undefined
  throw new Error('-envs aren\'t set correctly.') if c.envHosts is undefined or _.keys(c.envHosts).length < 2
  throw new Error('-paths aren\'t set correctly.') if c.paths is undefined or c.paths.length is 0

  c

processArgv = (args) ->
  while arg = args.shift()
    switch arg
      when '-browsers'
        browsers = parseBrowsers args.shift()

      when '-envs'
        envHosts = parseEnvHosts args.shift()
      when '-paths'
        paths = parsePaths args.shift()

      when '--report-format'
        reportFormat = args.shift().trim()

      when '--selenium-host'
        seleniumHost = args.shift().trim()

      else
        if arg.indexOf('.config.js') > 0
          config = require arg

  mergeAndValidateConfig seleniumHost, browsers, envHosts, paths, reportFormat, config

module.exports = processArgv