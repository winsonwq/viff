Viff = require '../../lib/viff.js'
sinon = require 'sinon'
_ = require 'underscore'

module.exports = 
  setUp: (callback) ->
    @config = 
      seleniumHost: 'http://localhost:4444/wd/hub'
      browsers: ['safari', 'firefox']
      compare: 
        build: 'http://localhost:4000'
        prod: 'http://www.ishouldbeageek'
      

    @viff = new Viff(@config.seleniumHost)
    
    @thenObj = then: ->
    @driver = 
      get: (url) -> 
      takeScreenshot: => @thenObj
      close: ->

    
    @getUrl = sinon.spy @driver, 'get'
    sinon.stub(@viff.builder, 'build').returns(@driver)
    sinon.stub(@thenObj, 'then').yields 'base64string'

    @links = ['/404.html', '/strict-mode']
    callback()
  tearDown: (callback) ->
    method.restore() for method in [
      @viff.builder.build
      @thenObj.then
    ]

    callback()

  'it should create correct builder': (test) ->
    test.equals @viff.builder.getServerUrl(), @config.seleniumHost
    test.done()

  'it should use correct browser to take screenshot': (test) ->
    useCapability = sinon.spy @viff.builder, 'withCapabilities'
      
    @viff.takeScreenshot('firefox', { build: 'http://localhost:4000' }, @links.first)
    test.ok useCapability.calledWith { browserName: 'firefox' }
    test.done()

  'it should visit the correct url to take screenshot': (test) ->
    envHost = 
      build: 'http://localhost:4000'

    @viff.takeScreenshot('firefox', envHost, @links.first)

    test.ok @getUrl.calledWith envHost.build + @links.first
    test.done()

  'it should invoke callback with the base64 string for screenshot': (test) ->
    envHost = 
      build: 'http://localhost:4000'
    
    callback = sinon.spy()
    @viff.takeScreenshot('firefox', envHost, @links.first, callback)

    test.ok callback.calledWith 'base64string'
    test.done()

  'it should take many screenshots according to config': (test) ->
    format = 
      safari:
        '/404.html': {}
        '/strict-mode': {}
      firefox:
        '/404.html': {}
        '/strict-mode': {}

    callback = (compares) -> 
      test.ok _.isEqual _.keys(format), _.keys(compares)
      test.ok _.isEqual _.keys(compares.safari), _.keys(compares.firefox)
      test.done()
    @viff.takeScreenshots @config.browsers, @config.compare, @links, callback

  'it should diff all screenshot': (test) ->
    compare = { diff: -> }
    compares = 
      safari:
        '/404.html': compare
        '/strict-mode': compare
      firefox:
        '/404.html': compare
        '/strict-mode': compare

    diff = sinon.spy(compare, 'diff')

    Viff.diff compares
    test.equals diff.callCount, 4
    test.done()
    
    
    
    