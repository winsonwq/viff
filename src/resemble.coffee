Resemble = require 'phantomjs-resemble'
resemblePool = []

module.exports =

  get: ->
    resembles = (r for r in resemblePool when r.running isnt true)
    if resembles[0]?
      return resembles[0]
    else
      r = new Resemble()
      r.running = false
      resemblePool.push r
      return r

  exit: ->
    for r in resemblePool
      r.exit()
      r.running = false
