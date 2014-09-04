resumer = require 'resumer'
helper = require '../lib/image.dataurl.helper'

module.exports = 
  base64ToStream: (imageData) ->
    data = new Buffer helper.toData(imageData), 'base64'
    resumer().queue(data).end()