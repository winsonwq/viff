module.exports =

  toDataURL: (data) ->
    data = data.toString('base64') unless typeof data == 'string'
    "data:image/png;base64,#{data}"


  toData: (dataUrl) ->
    dataUrl.replace('data:image/png;base64,', '')
