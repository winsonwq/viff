_ = require 'underscore'
Reporter = require '../../lib/reporter.js'

module.exports = 
  setUp: (callback) ->
    @compares = 
      chrome:
        '/404.html':
          isSameDimensions: true
          misMatchPercentage: 2.5
          analysisTime: 51
          images:
            build: 'aaa'
            prod: 'bbb'

        '/strict-mode':
          isSameDimensions: false
          misMatchPercentage: 4
          analysisTime: 52
          images:
            build: 'ccc'
            prod: 'ddd'

      firefox:
        '/404.html':
          isSameDimensions: true
          misMatchPercentage: 3
          analysisTime: 53
          images:
            build: 'eee'
            prod: 'fff'

        '/strict-mode':
          isSameDimensions: false
          misMatchPercentage: 0
          analysisTime: 54
          images:
            build: 'ggg'
            prod: 'hhh'

    callback()
  tearDown: (callback) ->
    callback()

  'it should contains 4 diffs': (test) ->
    reporter = new Reporter @compares 
    test.equals reporter.caseCount, 4
    test.done()

  'it should count how mamy diff is there': (test) ->
    reporter = new Reporter @compares
    test.equals reporter.diffCount, 3
    test.done()

  'it should return total analysisTime': (test) ->
    reporter = new Reporter @compares
    test.equals reporter.totalAnalysisTime, 210
    test.done()

  'it should generate correct html': (test) ->
    html = new Reporter(@compares).to 'html'
    
    test.ok html.indexOf('<h2>chrome</h2>') > 0
    test.ok html.indexOf('<h3>/404.html - 3% mismatch 53ms</h3>') > 0
    test.ok html.indexOf('data:image/png;base64,ggg') > 0
    test.ok html.indexOf('data-env="build"') > 0
    test.ok html.indexOf('<h1>Viff Report - (1 same in 4 cases) 210ms</h1>') > 0
    test.done()

  'it should generate correct json': (test) ->
    jsonStr = new Reporter(@compares).to 'json'
    json = JSON.parse jsonStr

    test.ok _.isEqual _.keys(json), ['chrome', 'firefox']
    test.ok _.isEqual _.keys(json.chrome['/404.html'].images), ['build', 'prod']
    test.ok _.isEqual _.values(json.chrome['/404.html'].images), ['aaa', 'bbb']
    test.done()
