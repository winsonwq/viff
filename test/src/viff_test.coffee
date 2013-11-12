sinon = require 'sinon'
_ = require 'underscore'
mr = require 'Mr.Async'
require('chai').should()

Viff = require '../../lib/viff.js'
webdriver = require 'selenium-webdriver'

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
      call: (fn) -> 
        fn()
        { addErrback: -> }
      get: (url) -> 
      takeScreenshot: => @thenObj
      quit: ->
    
    @getUrl = sinon.spy @driver, 'get'
    sinon.stub(@viff.builder, 'build').returns(@driver)
    sinon.stub(@thenObj, 'then').yields 'base64string'

    @mrThen = then: ->
    sinon.stub(mr, 'when').returns @mrThen
    sinon.stub(@mrThen, 'then').yields 'base64string', 1000, 'base64string2', 2000

    @links = ['/404.html', '/strict-mode']
    callback()
  tearDown: (callback) ->
    for method in [@viff.builder.build, @thenObj.then, mr.when, @mrThen.then]
      method.restore() 

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

  'it should invoke pre handler before take screenshot': (test) ->
    envHost = 
      build: 'http://localhost:4000'

    preHandler = sinon.spy()

    link = ['/path', preHandler]
    @viff.takeScreenshot('firefox', envHost, link)

    test.ok preHandler.calledWith @driver, webdriver
    test.done()

  'it should use correct path when set pre handler': (test) ->
    links = [['/404.html', (driver, webdriver) -> ]]
    callback = (compares) -> 
      test.equals _.first(_.keys(compares.firefox)), '/404.html'
      test.done()
    @viff.takeScreenshots @config.browsers, @config.compare, links, callback

  'it should use correct path string when set selector': (test) ->
    links = [['/404.html', '#page', (driver, webdriver) -> ]]
    sinon.stub(Viff, 'dealWithPartial').callsArgWith(3, 'partialBase64Img');

    callback = (compares) -> 
      Viff.dealWithPartial.restore()
      
      test.equals _.first(_.keys(compares.firefox)), '/404.html (#page)'
      test.done()

    @viff.takeScreenshots @config.browsers, @config.compare, links, callback

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

  'it should take fire many times `tookScreenshot` handler': (test) ->
    format = 
      safari:
        '/404.html': {}
        '/strict-mode': {}
      firefox:
        '/404.html': {}
        '/strict-mode': {}

    tookScreenshotHandler = sinon.spy()
    @viff.on 'tookScreenshot', tookScreenshotHandler

    callback = (compares) -> 
      test.equals tookScreenshotHandler.callCount, 8
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

  'it should take partial screenshot according to selecor': (test) ->
    envHost = 
      build: 'http://localhost:4000'

    preHandler = sinon.spy()
    link = ['/path', 'selector', preHandler]
    partialTake = sinon.stub(Viff, 'dealWithPartial').returns { then: -> }

    @viff.takeScreenshot('firefox', envHost, link)
    partialTake.restore()

    test.ok partialTake.calledWith 'base64string', @driver, 'selector'
    test.done()

  'it should run pre-handler when using selector': (test) ->
    envHost = 
      build: 'http://localhost:4000'

    preHandler = sinon.spy()
    link = ['/path', 'selector', preHandler]
    partialTake = sinon.stub(Viff, 'dealWithPartial').returns { then: -> }

    @viff.takeScreenshot('firefox', envHost, link)
    partialTake.restore()

    test.ok preHandler.calledWith @driver, webdriver
    test.done()

  'it should fire testcase `tookScreenshot` hook': (test) ->
    envHost = 
      build: 'http://localhost:4000'

    link = ['/path', ->]

    @viff.on 'tookScreenshot', (browserName, host, url, duration, base64Img) ->
      test.equals browserName, 'firefox'
      test.equals host, envHost
      test.equals url, link
      test.equals base64Img, 'base64string'
      test.done() 
    
    @viff.takeScreenshot('firefox', envHost, link)

  'it should parse correct url info when only set path': (test) ->
    [url, selector, preHandler] = Viff.parseUrl '/'
    test.equals url, '/'
    test.equals selector, undefined
    test.equals preHandler, undefined
    test.done()

  'it should parse correct url info when only set path and pre-handler': (test) ->
    pre = ->
    [url, selector, preHandler] = Viff.parseUrl ['/', pre]
    test.equals url, '/'
    test.equals selector, undefined
    test.equals preHandler, pre
    test.done()

  'it should parse correct url info when set path, selector and pre-handler': (test) ->
    pre = ->
    [url, selector, preHandler] = Viff.parseUrl ['/', '#id', pre]
    test.equals url, '/'
    test.equals selector, '#id'
    test.equals preHandler, pre
    test.done()

  'it should parse correct urlinfo when set description and path': (test) ->
    [url, selector, preHandler, description] = Viff.parseUrl { 'this is description of testcase' : '/' }
    test.equals description, 'this is description of testcase'
    test.equals url, '/'
    test.done()
  
  'it should return correct path url for testcase when set description and selector': (test) ->
    [url, selector, preHandler, description] = Viff.parseUrl { 'this is description of testcase' : ['/', '#selector'] }
    test.equals description, 'this is description of testcase'
    test.equals url, '/'
    test.equals selector, '#selector'
    test.done()

  'it should return correct path key for testcase when set description' : (test) ->
    test.equals 'this is testcase description', Viff.getPathKey { 'this is testcase description' : '/' }
    test.done()


  'it should construct cases': (test) ->
    cases = @viff.constructCases(@config.browsers, @config.compare, @links)
    cases.length.should.equal 4
    _.first(cases).browser.should.equal 'safari'
    test.done()


    
    
    