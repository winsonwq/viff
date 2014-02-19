_ = require 'underscore'
sinon = require 'sinon'
should = require('chai').should()
path = require 'path'

processArgv = require '../../lib/process.argv.js'

describe 'process argv', ->

  it 'should parse correct arguments', () ->
    argv = [ 
      'node', 
      '/Users/tw/Projects/viff/lib/index.js', 
      '-browsers', 
      'firefox,chrome', 
      '-envs', 
      'build=http://localhost:4000,prod=http://ishouldbeageek.me', 
      '-paths', 
      '/404.html',
      '--report-format',
      'html',
      '--selenium-host',
      'http://localhost:4444/wd/hub',
      '-grep',
      '404'
    ]

    config = processArgv argv

    _.keys(config).should.eql ['seleniumHost', 'browsers', 'envHosts', 'paths', 'reportFormat', 'grep']
    config.browsers.should.eql ['firefox', 'chrome']
    config.envHosts.should.eql { build: 'http://localhost:4000', prod: 'http://ishouldbeageek.me' }
    config.paths.should.eql ['/404.html']
    config.reportFormat.should.eql 'html'
    config.seleniumHost.should.eql 'http://localhost:4444/wd/hub'
    config.grep.should.eql '404'

  it 'should ignore the blank between ","', () ->
    argv = [ 
      'node', 
      '/Users/tw/Projects/viff/lib/index.js', 
      '-browsers', 
      ' firefox , chrome ',
      '-envs', 
      'build=http://localhost:4000,prod=http://ishouldbeageek.me', 
      '-paths', 
      '/404.html',
      '--selenium-host',
      'http://localhost:4444/wd/hub'
    ]

    config = processArgv argv
    config.browsers.should.eql ['firefox', 'chrome']

  it 'should ignore value is empty', () ->
    argv = [ 
      'node', 
      '/Users/tw/Projects/viff/lib/index.js', 
      '-browsers', 
      ' firefox , chrome ',
      '-envs', 
      'build=http://localhost:4000,prod=http://ishouldbeageek.me', 
      '-paths', 
      '/404.html, ',
      '--selenium-host',
      'http://localhost:4444/wd/hub'
    ]

    config = processArgv argv
    config.paths.should.eql ['/404.html']
  
  it 'should set default browser "firefox" when no browsers argument', () ->
    argv = [ 
      'node', 
      '/Users/tw/Projects/viff/lib/index.js',
      '-envs', 
      'build=http://localhost:4000,prod=http://ishouldbeageek.me', 
      '-paths', 
      '/404.html, ',
      '--selenium-host',
      'http://localhost:4444/wd/hub'
    ]

    config = processArgv argv
    config.browsers.should.eql ['firefox']

  it 'should set default report format "html" when no --report-format', () ->
    argv = [ 
      'node', 
      '/Users/tw/Projects/viff/lib/index.js',
      '-envs', 
      'build=http://localhost:4000,prod=http://ishouldbeageek.me', 
      '-paths', 
      '/404.html, ',
      '--selenium-host',
      'http://localhost:4444/wd/hub'
    ]

    config = processArgv argv
    config.reportFormat.should.eql 'html'

  it 'should throw error when envHosts is not set', () ->
    argv = [ 
      'node', 
      '/Users/tw/Projects/viff/lib/index.js',
      '-paths', 
      '/404.html, ',
      '--selenium-host',
      'http://localhost:4444/wd/hub'
    ]

    (()-> processArgv argv).should.throw()

  it 'should throw error when paths is not set', () ->
    argv = [ 
      'node', 
      '/Users/tw/Projects/viff/lib/index.js',
      '-envs', 
      'build=http://localhost:4000,prod=http://ishouldbeageek.me',
      '--selenium-host',
      'http://localhost:4444/wd/hub'
    ]

    (() -> config = processArgv argv).should.throw()

  it 'will override configuration when set custom.config.js and args at same time', () ->
    argv = [ 
      'node', 
      '/Users/tw/Projects/viff/lib/index.js',
      '-envs', 
      'build=http://localhost:4000,prod=http://ishouldbeageek.me', 
      './test/src/test.config.js',
      '-paths', 
      '/404.html',
      '--selenium-host',
      'http://localhost:4444/wd/hub'
    ]

    config = processArgv argv

    config.browsers.should.eql ['safari']
    config.envHosts.should.eql { build: 'http://localhost:4000', prod: 'http://ishouldbeageek.me' }
    config.paths.should.eql ['/404.html']
    config.reportFormat.should.eql 'json'

  it 'will override configuration when only use custom.config.js', () ->
    argv = [ 
      'node', 
      '/Users/tw/Projects/viff/lib/index.js',
      './test/src/correct.config.js'
    ]

    config = processArgv argv

    config.browsers.should.eql ['safari', 'firefox']
    config.envHosts.should.eql { custom: 'http://localhost:4000', custom2: 'http://localhost:4001' }
    config.paths.should.eql [
      '/strict-mode', 
      { 'test case description': ['/', '#selector'] }, 
      ['/hello-world', '#selector2']
    ]
    config.reportFormat.should.eql 'json'

  it 'should return config for matched cases', () ->
    argv = [ 
      'node', 
      '/Users/tw/Projects/viff/lib/index.js',
      '-paths', 
      '/404.html, /find-path, /hello',
      './test/src/correct.config.js',
      '-grep', '-'
    ]

    config = processArgv argv
    config.paths.length.should.equal 1
    config.paths.should.contain '/find-path'

  it 'should return config for matched cases when only using config.js', () ->
    argv = [ 
      'node', 
      '/Users/tw/Projects/viff/lib/index.js',
      './test/src/correct.config.js',
      '-grep', '-'
    ]

    config = processArgv argv
    
    config.paths.length.should.equal 2
    config.paths[0].should.equal '/strict-mode'
    config.paths[1][0].should.equal '/hello-world'

  it 'should return help menu when only executing "viff"', () ->
    argv = [
      'node'
      '/Users/tw/Projects/viff/lib/index.js'
    ]

    config = processArgv argv
    (typeof(config)).should.eql 'string'
    (config.indexOf('Usage:') >= 0).should.be.true

  it 'should accept config object input as default config info', ->
    argv = require '../src/correct.config'
    config = processArgv argv
    config.paths.length.should.equal 3






  

