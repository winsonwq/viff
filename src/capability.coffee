_ = require 'underscore'

class Capability

  constructor: (capObj) ->
    if _.isString capObj
      @browserName = capObj
    else 
      (@[prop] = capObj[prop] || '') for prop of capObj when capObj.hasOwnProperty prop
          
  key: ->
    key = ''
    if @os || @os_version || @browser || @browser_version
      key = @._mergeProp @os, @os_version, @browser, @browser_version

    else if @platform || @device || @browserName
      key = @._mergeProp @platform, @device, @browserName

    key

  _mergeProp: (props...) ->
    key = ''
    key += prop + ' - ' for prop in props when prop
    key = key.substring 0, key.length - 3
    key


module.exports = Capability