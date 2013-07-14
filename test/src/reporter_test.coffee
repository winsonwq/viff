_ = require 'underscore'
reporter = require '../../lib/reporter.js'

module.exports = 
  setUp: (callback) ->
    @compares = 
      chrome:
        '/404.html':
          build: 'aaa'
          prod: 'bbb'

        '/strict-mode':
          build: 'ccc'
          prod: 'ddd'

      firefox:
        '/404.html':
          build: 'eee'
          prod: 'fff'

        '/strict-mode':
          build: 'ggg'
          prod: 'hhh'

    callback()
  tearDown: (callback) ->
    callback()

  'it should generate correct html': (test) ->
    html = reporter.generate 'html', @compares

    test.ok html.indexOf('<h2>chrome</h2>') > 0
    test.ok html.indexOf('<h3>/404.html</h3>') > 0
    test.ok html.indexOf('data:image/png;base64,ggg') > 0
    test.ok html.indexOf('data-env="build"') > 0
    test.done()

  'it should generate correct json': (test) ->
    jsonStr = reporter.generate 'json', @compares
    json = JSON.parse jsonStr

    test.ok _.isEqual _.keys(json), ['chrome', 'firefox']
    test.ok _.isEqual _.keys(json.chrome['/404.html']), ['build', 'prod']
    test.ok _.isEqual _.values(json.chrome['/404.html']), ['aaa', 'bbb']
    test.done()
