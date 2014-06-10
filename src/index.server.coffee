connect = require 'connect'
http = require 'http'
multipart = require 'connect-multiparty'
fs = require 'fs'

Viff = require './viff'
imgGen = require './image.generator'
Testcase = require './testcase'
Capability = require './capability'
require './color.helper.js'
resemble = require './resemble'
partialCanvas = require './canvas.drawimage'


cases = {}
resolvedCases = []

reset = ->
  cases = {}
  resolvedCases.length = 0

prepareCachedCase = (c, capability, host, name, url, screenshot) ->
  c.capabilities.push capability
  c.hosts.push host
  c.names.push name
  c.screenshots.push screenshot
  c.url = url
  c

handleTestcase = (req, callback) ->
  url = JSON.parse req.body.url
  tkey = Testcase.getPathKey url

  unless cases[tkey]
    cases[tkey] = capabilities : [], names: [], hosts: [], screenshots: []

  prepareCachedCase(
    cases[tkey],
    new Capability(JSON.parse req.body.capabilities),
    req.body.host,
    req.body.name,
    url,
    fs.readFileSync(req.files.image.path)
  )

  if cases[tkey].capabilities.length >= 2

    c = new Testcase(
      cases[tkey].capabilities[0], cases[tkey].capabilities[1],
      cases[tkey].hosts[0], cases[tkey].hosts[1],
      cases[tkey].names[0], cases[tkey].names[1],
      cases[tkey].url
      )

    Viff.runCase c, cases[tkey].screenshots[0], cases[tkey].screenshots[1], (_case) ->
      imgGen.generateByCase _case
      resolvedCases.push _case
      console.log "  - #{_case.browser.info} #{_case.key().greyColor}"
      callback && callback(null, _case)
  else
    callback && callback()

caseHandler = (req, resp) ->

  if req.method is 'POST' and req.url is '/'
    handleTestcase req, ->
      resp.end()
  else if req.method is 'GET'
    if resolvedCases.length > 0 and req.url is '/generate-report'
      imgGen.generateReport resolvedCases
      reset()
      console.log '  report.json generated.'
      resp.end()
    else if req.url is '/end'
      console.log '  Done.'
      resp.end()
      resemble.exit()
      partialCanvas.exit()
      process.exit 0
  else
    resp.end()

app = connect()
app.use(multipart()).use(caseHandler)

imgGen.reset()
http.createServer(app).listen(3000);
console.log 'Viff is waiting for screenshots...\n'
