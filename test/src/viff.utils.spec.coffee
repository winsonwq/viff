# sinon = require 'sinon'
# _ = require 'underscore'
# Q = require 'q'
path = require 'path'
# wrench = require 'wrench'
# es = require 'event-stream'
fs = require 'fs'
Stream = require 'stream'
vfs = require 'vinyl-fs'
helper = require '../../lib/image.dataurl.helper'


require('chai').should()

viffUtils = require '../../lib/viff.utils'

describe 'util', ->
  it 'should stream out the same base64 data', (done) ->
    image = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsQAAA7EAZUrDhsAAAANSURBVBhXYzh8+PB/AAffA0nNPuCLAAAAAElFTkSuQmCC"

    _image = ''
    imagefile = fs.createWriteStream(path.join(process.cwd(), './test/diff0.png'),{
        flags: 'w',
        encoding: 'base64',
        mode: '0666'
      })
    viffUtils.base64ToStream(image)
      # .on 'data', (data) ->
      #   console.log(_image.toString())
      .on 'end', ->
        done()
      .pipe(imagefile)

      # .push(null)
  # it 'should load a image as base 64 and write one', (done) ->
  #   imageData = ''
  #   vfs.src('./test/diff.png')
  #     .pipe(vfs.dest('./test/diff3.png'))
  #     .on 'data', (data) ->
  #       console.log(data.toString())
  #       imageData = [imageData, data].join('')
  #     .on 'end', ->
  #       console.log imageData
        # viffUtils.base64ToStream(helper.toData(imageData))
        #   .pipe(vfs.dest('./test/diff2.png'))
        #   .on 'end', ->
        # done()
