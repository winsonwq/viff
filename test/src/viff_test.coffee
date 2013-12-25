sinon = require 'sinon'
_ = require 'underscore'
mr = require 'Mr.Async'
Comparison = require '../../lib/comparison.js'
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

    @links = ['/404.html', '/strict-mode']

    # for comparison

    @diffObj =
      isSameDimensions: true
      misMatchPercentage: "2.84"
      analysisTime: 54
      getImageDataUrl: () -> 'ABCD'

    sinon.stub(Comparison, 'compare').callsArgWith 2, @diffObj

    callback()
  tearDown: (callback) ->
    for method in [@viff.builder.build, @thenObj.then, Comparison.compare]
      method.restore() 

    callback()

  'it should create correct builder': (test) ->
    test.equals @viff.builder.getServerUrl(), @config.seleniumHost
    test.done()

  'it should use correct browser to take screenshot': (test) ->
    useCapability = sinon.spy @viff.builder, 'withCapabilities'
      
    @viff.takeScreenshot('firefox', 'http://localhost:4000', @links.first)
    test.ok useCapability.calledWith { browserName: 'firefox' }
    test.done()

  'it should visit the correct url to take screenshot': (test) ->
    host = 'http://localhost:4000'
    @viff.takeScreenshot('firefox', host, @links.first)

    test.ok @getUrl.calledWith host + @links.first
    test.done()

  'it should invoke callback with the base64 string for screenshot': (test) ->
    callback = sinon.spy()
    @viff.takeScreenshot('firefox', 'http://localhost:4000', @links.first, callback)

    test.equals callback.firstCall.args[0].toString('base64'), 'base64string'
    test.done()

  'it should invoke pre handler before take screenshot': (test) ->

    preHandler = sinon.spy()

    link = ['/path', preHandler]
    @viff.takeScreenshot('firefox', 'http://localhost:4000', link)

    test.ok preHandler.calledWith @driver, webdriver
    test.done()

  'it should use correct path when set pre handler': (test) ->
    links = [['/404.html', (driver, webdriver) -> ]]
    callback = (cases) -> 
      test.equals _.first(cases).url[0], '/404.html'
      test.done()
    @viff.takeScreenshots @config.browsers, @config.compare, links, callback

  'it should use correct path string when set selector': (test) ->
    links = [['/404.html', '#page', (driver, webdriver) -> ]]
    sinon.stub(Viff, 'dealWithPartial').callsArgWith(3, 'partialBase64Img');

    callback = (cases) -> 
      Viff.dealWithPartial.restore()
      
      test.equals _.first(cases).url[0], '/404.html'
      test.equals _.first(cases).url[1], '#page'
      test.done()

    @viff.takeScreenshots @config.browsers, @config.compare, links, callback

  'it should take many screenshots according to config': (test) ->

    callback = (cases) ->
      test.equals cases.length, 4
      test.equals _.first(cases).url, '/404.html'
      test.done()

    @viff.takeScreenshots @config.browsers, @config.compare, @links, callback

  'it should take fire many times `afterEach` handler': (test) ->
    afterEachHandler = sinon.spy()
    @viff.on 'afterEach', afterEachHandler

    callback = (compares) -> 
      test.equals afterEachHandler.callCount, 4
      test.done()
    
    @viff.takeScreenshots @config.browsers, @config.compare, @links, callback

  'it should take fire only once `before` handler': (test) ->
    beforeHandler = sinon.spy()
    @viff.on 'before', beforeHandler

    callback = (compares) -> 
      test.equals beforeHandler.callCount, 1
      test.done()
    
    @viff.takeScreenshots @config.browsers, @config.compare, @links, callback

  'it should take fire only once `after` handler': (test) ->
    beforeHandler = sinon.spy()
    @viff.on 'before', beforeHandler

    callback = (compares) -> 
      test.equals beforeHandler.callCount, 1
      test.done()
    
    @viff.takeScreenshots @config.browsers, @config.compare, @links, callback

  'it should take partial screenshot according to selecor': (test) ->

    preHandler = sinon.spy()
    link = ['/path', 'selector', preHandler]
    partialTake = sinon.stub(Viff, 'dealWithPartial').returns { then: -> }

    @viff.takeScreenshot('firefox', 'http://localhost:4000', link)
    partialTake.restore()

    test.ok partialTake.calledWith 'base64string', @driver, 'selector'
    test.done()

  'it should run pre-handler when using selector': (test) ->

    preHandler = sinon.spy()
    link = ['/path', 'selector', preHandler]
    partialTake = sinon.stub(Viff, 'dealWithPartial').returns { then: -> }

    @viff.takeScreenshot('firefox', 'http://localhost:4000', link)
    partialTake.restore()

    test.ok preHandler.calledWith @driver, webdriver
    test.done()

  'it should fire testcase `afterEach` hook': (test) ->
    links = ['/404.html']
    @viff.once 'afterEach', (c, duration) -> 
      test.equals c.browser, 'safari'
      test.equals c.url, '/404.html'

    @viff.takeScreenshots @config.browsers, @config.compare, links, -> test.done()

  'it should fire testcase `before` hook': (test) ->
    links = ['/404.html']
    @viff.once 'before', (cases) -> 
      test.equals cases.length, 2

    @viff.takeScreenshots @config.browsers, @config.compare, links, -> test.done()

  'it should fire testcase `after` hook': (test) ->
    links = ['/404.html']
    @viff.once 'after', (cases) -> 
      test.equals cases.length, 2

    @viff.takeScreenshots @config.browsers, @config.compare, links, -> test.done()

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
    cases = Viff.constructCases(@config.browsers, @config.compare, @links)
    cases.length.should.equal 4
    _.first(cases).from.browser.should.equal 'safari'
    test.done()

  'it should construct cases when set comparing cross browsers': (test) ->
    browsers = ['chrome:firefox', 'firefox'];
    cases = Viff.constructCases(browsers, @config.compare, @links)
    cases.length.should.equal 6
    _.first(cases).from.name.should.equal 'build'
    test.done()  



    
    
    