fs = require 'fs'
path = require 'path'
{spawn} = require 'child_process'

INPUT_PATH = path.join __dirname, 'src'
OUTPUT_PATH = path.join __dirname, 'lib'

CMD = if process.platform == 'win32' then 'coffee.cmd' else 'coffee'

task 'build', 'Build lib/ form src/', ->
  coffee = spawn CMD, ['-o', OUTPUT_PATH, '-c', INPUT_PATH]
  coffee.stderr.pipe process.stderr
  coffee.stdout.pipe process.stdout
  coffee.on 'error', (err) ->
    console.error err
