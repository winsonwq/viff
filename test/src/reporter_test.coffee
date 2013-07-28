_ = require 'underscore'
reporter = require '../../lib/reporter.js'

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
          images:
            isSameDimensions: false
            misMatchPercentage: 9
            analysisTime: 54
            build: 'ggg'
            prod: 'hhh'

    callback()
  tearDown: (callback) ->
    callback()

  'it should generate correct html': (test) ->
    html = reporter.generate 'html', @compares

    test.ok html.indexOf('<h2>chrome</h2>') > 0
    test.ok html.indexOf('<h3>/404.html 53ms</h3>') > 0
    test.ok html.indexOf('data:image/png;base64,ggg') > 0
    test.ok html.indexOf('data-env="build"') > 0
    test.done()

  'it should generate correct json': (test) ->
    jsonStr = reporter.generate 'json', @compares
    json = JSON.parse jsonStr

    test.ok _.isEqual _.keys(json), ['chrome', 'firefox']
    test.ok _.isEqual _.keys(json.chrome['/404.html'].images), ['build', 'prod']
    test.ok _.isEqual _.values(json.chrome['/404.html'].images), ['aaa', 'bbb']
    test.done()
