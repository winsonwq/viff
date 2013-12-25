class Case

  constructor: (@browser, browserFrom, browserTo, hostFrom, hostTo, nameFrom, nameTo, @url) ->
    @from = 
      browser: browserFrom
      name: nameFrom
      host: hostFrom
    @to = 
      browser: browserTo
      name: nameTo
      host: hostTo

module.exports = Case