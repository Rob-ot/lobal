
assert = require 'assert'
fs = require 'fs'
mockFs = require 'mock-fs'

lobal = require './lobal'

# ../lib/node_modules/n/bin/n

describe 'packageVersion', ->
  it 'exists', ->
    assert.ok lobal.packageVersion

  it 'finds the correct package from the project root', (done) ->
    mockFs
      '/home/rob/myproject':
        'node_modules':
          'submodule':
            'package.json': new Buffer JSON.stringify version: '1.2.3'

    lobal.packageVersion 'submodule', '/home/rob/myproject', (err, version) ->
      assert.equal version, '1.2.3'
      done()

