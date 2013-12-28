_ = require 'underscore'

class Capability

  constructor: (capObj) ->
    if _.isString capObj
      @browserName = capObj
    else 
      @browserName = capObj.browserName

module.exports = Capability