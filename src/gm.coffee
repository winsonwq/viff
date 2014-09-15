gm = require "gm"

module.exports =
  diff: (imgA, imgB, imgDiff, cb) ->
    #image file path only
    gm.compare(imgA, imgB, {
      file: imgDiff,
      highlightColor: 'red',
      tolerance: 0.02
      }, cb)
  partial: (imagePath, w, h, x, y, cb) ->
    gm(imagePath)
      .crop(w, h, x, y)
      .stream()
