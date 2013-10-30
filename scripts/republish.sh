#!/usr/bin/env coffee

spawn = require('child_process').spawn
path = require 'path'

config = require '../package.json'
version = config.version

(spawn 'npm', ['unpublish', "viff@#{version}"]).on 'close', ->
  (spawn 'npm', ['publish', path.dirname __dirname ]).on 'close', ->
    console.log "republishing viff@#{version} is done."

