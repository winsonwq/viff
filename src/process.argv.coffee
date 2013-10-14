_ = require 'underscore'
path = require 'path'

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

checkIfNeedHelp = (args) ->
  argsCollection = ['-browsers', '-envs', '-paths', '--report-format', '--selenium-host']
  needHelp = true
  for param in args
    if argsCollection.indexOf(param) >= 0 || param.indexOf('.config.js') > 0
      needHelp = false
      break

  needHelp

help = ->
  """
  
  Usage: viff [options] [config file path]

  Options:

    -browsers <borwser1/*, browser2 ...*/>     config the browsers using browser name, by default firefox 
    -envs <env1=url1, env2=url2>               config two environments, env1 and env2 could be updated
    -paths <path1/*, path2 ...*/>              config the paths to compare
    --report-format <format>                   config the output format in file/json/html, by default file
    --selenium-host <host>                     config selenium host, such as "http://localhost:4444/wd/hub"

  Config File Path:
    
    /path/to/config_file.config.js             a config file with a tail of '.config.js'

  Demo:

    viff --selenium-host http://localhost:4444/wd/hub 
         -browsers "firefox,chrome" 
         -envs build=http://localhost:4000,prod=http://ishouldbeageek.me 
         -paths "/404.html,/page2" 
         --report-format file
         /Users/xx/test.config.js

  Read More: https://github.com/winsonwq/viff
  
  """

processArgv = (args) ->
  if checkIfNeedHelp(args)
    return help()

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
          config = require path.resolve process.cwd(), arg

  mergeAndValidateConfig seleniumHost, browsers, envHosts, paths, reportFormat, config

module.exports = processArgv