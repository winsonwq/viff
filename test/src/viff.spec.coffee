sinon = require 'sinon'
_ = require 'underscore'
mr = require 'Mr.Async'
Comparison = require '../../lib/comparison.js'
require('chai').should()

Viff = require '../../lib/viff.js'
webdriver = require 'selenium-webdriver'
Capability = require '../../lib/capability'

describe 'viff', ->

  beforeEach (callback) ->
    @config = 
      seleniumHost: 'http://localhost:4444/wd/hub'
      browsers: ['safari', 'firefox']
      compare: 
        build: 'http://localhost:4000'
        prod: 'http://www.ishouldbeageek'
      

    @viff = new Viff(@config.seleniumHost)
    
    @driver = 
      get: (url) ->
      takeScreenshot: => 
      quit: ->

    @getUrl = sinon.spy @driver, 'get'

    @init = sinon.stub(@viff.builder, 'init').returns(@driver)
    sinon.stub(@driver, 'takeScreenshot').callsArgWithAsync 0, null, 'base64string'

    @links = ['/404.html', '/strict-mode']

    # for comparison

    @diffObj =
      isSameDimensions: true
      misMatchPercentage: "2.84"
      analysisTime: 54
      getImageDataUrl: () -> 'ABCD'

    sinon.stub(Comparison, 'compare').callsArgWith 2, @diffObj

    callback()
  afterEach (callback) ->
    for method in [@viff.builder.init, @driver.takeScreenshot, Comparison.compare]
      method.restore() 

    callback()

  it 'should use correct browser to take screenshot', (done) ->
    @viff.takeScreenshot('firefox', 'http://localhost:4000', @links.first).done =>
      @init.firstCall.args[0].browserName.should.eql 'firefox'
      done()

  it 'should visit the correct url to take screenshot', (done) ->
    host = 'http://localhost:4000'
    @viff.takeScreenshot('firefox', host, @links.first).done -> done()

    @getUrl.calledWith(host + @links.first).should.be.true

  it 'should invoke callback with the base64 string for screenshot', (done) ->
    callback = ([base64img, ex]) ->
      base64img.toString('base64').should.eql 'base64string'
      done()

    @viff.takeScreenshot('firefox', 'http://localhost:4000', @links.first, callback)

  it 'should invoke pre handler before take screenshot', (done) ->
    preHandler = sinon.spy()

    link = ['/path', preHandler]
    @viff.takeScreenshot('firefox', 'http://localhost:4000', link).done => 
      preHandler.calledWith(@driver).should.be.true
      done()

  it 'should use correct path when set pre handler', (done) ->
    links = [['/404.html', (driver, webdriver) -> ]]
    callback = ([cases, ex]) -> 
      _.first(cases).url[0].should.eql '/404.html'
      done()
    @viff.run Viff.constructCases(@config.browsers, @config.compare, links), callback

  it 'should use correct path string when set selector', (done) ->
    links = [['/404.html', '#page', (driver, webdriver) -> ]]
    dealWithPartial = sinon.stub(Viff, 'dealWithPartial').callsArgWithAsync(3, 'partialBase64Img');

    callback = ([cases, ex]) -> 
      _.first(cases).url[0].should.eql '/404.html'
      _.first(cases).url[1].should.eql '#page'
      dealWithPartial.restore()
      done()

    @viff.run Viff.constructCases(@config.browsers, @config.compare, links), callback

  it 'should take many screenshots according to config', (done) ->

    callback = ([cases, ex]) ->
      cases.length.should.eql 4
      _.first(cases).url.should.eql '/404.html'
      done()

    @viff.run Viff.constructCases(@config.browsers, @config.compare, @links), callback

  it 'should take fire many times `beforeEach` handler', (done) ->
    beforeEachHandler = sinon.spy()
    @viff.on 'beforeEach', beforeEachHandler

    callback = ([compares, ex]) -> 
      beforeEachHandler.callCount.should.eql 4
      done()
    
    @viff.run Viff.constructCases(@config.browsers, @config.compare, @links), callback

  it 'should take fire many times `afterEach` handler', (done) ->
    afterEachHandler = sinon.spy()
    @viff.on 'afterEach', afterEachHandler

    callback = ([compares, ex]) -> 
      afterEachHandler.callCount.should.eql 4
      done()
    
    @viff.run Viff.constructCases(@config.browsers, @config.compare, @links), callback

  it 'should take fire only once `before` handler', (done) ->
    beforeHandler = sinon.spy()
    @viff.on 'before', beforeHandler

    callback = ([compares, ex]) -> 
      beforeHandler.callCount.should.eql 1
      done()
    
    @viff.run Viff.constructCases(@config.browsers, @config.compare, @links), callback

  it 'should take fire only once `after` handler', (done) ->
    beforeHandler = sinon.spy()
    @viff.on 'before', beforeHandler

    callback = ([compares, ex]) -> 
      beforeHandler.callCount.should.eql 1
      done()
    
    @viff.run Viff.constructCases(@config.browsers, @config.compare, @links), callback

  it 'should take partial screenshot according to selecor', (done) ->

    preHandler = sinon.spy()
    link = ['/path', 'selector', preHandler]
    partialTake = sinon.stub(Viff, 'dealWithPartial').callsArgWithAsync 3, new Buffer('partialBase64Img')

    @viff.takeScreenshot new Capability('firefox'), 'http://localhost:4000', link, (img) =>
      partialTake.calledWith('base64string', @driver, 'selector').should.be.true  
      partialTake.restore()
      done();

  it 'should run pre-handler when using selector', (done) ->

    preHandler = sinon.spy()
    link = ['/path', 'selector', preHandler]
    partialTake = sinon.stub(Viff, 'dealWithPartial').callsArgWithAsync 3, new Buffer('partialBase64Img')

    @viff.takeScreenshot('firefox', 'http://localhost:4000', link).done =>
      preHandler.calledWith(@driver).should.be.true
      partialTake.restore()
      done()


  it 'should fire testcase `afterEach` hook', (done) ->
    links = ['/404.html']
    @viff.once 'afterEach', (c, duration) -> 
      c.browser.should.eql 'safari'
      c.url.should.eql '/404.html'

    @viff.run Viff.constructCases(@config.browsers, @config.compare, links), -> done()

  it 'should fire testcase `before` hook', (done) ->
    links = ['/404.html']
    @viff.once 'before', (cases) -> 
      cases.length.should.eql 2

    @viff.run Viff.constructCases(@config.browsers, @config.compare, links), -> done()

  it 'should fire testcase `after` hook', (done) ->
    links = ['/404.html']
    @viff.once 'after', (cases) -> 
      cases.length.should.eql 2

    @viff.run Viff.constructCases(@config.browsers, @config.compare, links), -> done()

  it 'should construct cases', () ->
    cases = Viff.constructCases(@config.browsers, @config.compare, @links)
    cases.length.should.equal 4
    _.first(cases).from.capability.browserName.should.equal 'safari'

  it 'should construct cases when set comparing cross browsers', () ->
    browsers = [['chrome', 'firefox'], 'firefox'];
    cases = Viff.constructCases(browsers, @config.compare, @links)
    cases.length.should.equal 6
    _.first(cases).from.name.should.equal 'build'



    
    
    