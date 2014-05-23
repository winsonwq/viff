phantom = require 'phantom'

nope = () ->

class CanvasDrawImage

  constructor: () ->

  preparePhantom: (cb) ->
    platform = if process.platform == 'win32' then 'phantomjs.cmd' else 'phantomjs';
    usingWeak = process.platform != 'win32';

    if !@cachedPh or !@cachedPage
      phantom.create (ph) =>
        ph.createPage (page) =>
          @cachedPh = ph
          @cachedPage = page
          cb.call(this)
      , {
        binary: platform,
        dnodeOpts: {
          weak: usingWeak
        }
      }
    else cb.call(this)

  drawImage: (imageDataUrl, location, size, cb) ->
    @preparePhantom =>

      resultDataUrl = ''
      @cachedPage.set 'onCallback', (data) ->
        if data.chunk
          resultDataUrl += data.chunk;
        else if data.done
          cb resultDataUrl

      @cachedPage.evaluate (dataUrl, loc, sz) ->
        image = new Image()
        image.onload = ->
          cvs = document.createElement 'canvas'
          [cvs.width, cvs.height] = [sz.width, sz.height]

          ctx = cvs.getContext '2d'
          ctx.drawImage image, loc.x, loc.y, sz.width, sz.height, 0, 0, sz.width, sz.height

          if typeof window.callPhantom == 'function'
            dataUrl = cvs.toDataURL()
            i = 0

            while i < dataUrl.length
              window.callPhantom { chunk : dataUrl.slice(i, i + 1024) }
              i+= 1024

            window.callPhantom { done: true }

        image.src = dataUrl

      , nope, imageDataUrl, location, size


  exit: () ->
    @cachedPh.exit()
    @cachedPh = @cachedPage = null

module.exports = new CanvasDrawImage
