
assert = require 'assert'
fs = require 'fs'
mockFs = require 'mock-fs'

lobal = require './lobal'

bashFile = '/fakehome/.bash_profile'

lobal.log = -> # supress logs

# mock these fns to work with mockFs
lobal.shimsDirectory = '/fakehome/.lobal_shims'
lobal.findBashFile = (cb) -> cb bashFile

describe 'findProjectDirectory', ->
  it 'exists', ->
    assert.ok lobal.findProjectDirectory

  it 'finds the project directory from the project root via node_modules', (done) ->
    mockFs
      '/projects/lobal':
        'node_modules':
          'submodule': new Buffer('1')

    lobal.findProjectDirectory '/projects/lobal', (err, projectDirectory) ->
      assert.ifError err
      assert.strictEqual projectDirectory, '/projects/lobal'
      done()

  it 'finds the project directory from the project root via package.json', (done) ->
    mockFs
      '/projects/lobal':
        'package.json': new Buffer('1')

    lobal.findProjectDirectory '/projects/lobal', (err, projectDirectory) ->
      assert.ifError err
      assert.strictEqual projectDirectory, '/projects/lobal'
      done()

  it 'finds the project directory from a project subfolder via node_modules', (done) ->
    mockFs
      '/projects/lobal':
        'node_modules':
          'submodule': new Buffer('1')
        'stuff':
          'subfolder':
            'subfile': new Buffer('1')

    lobal.findProjectDirectory '/projects/lobal/stuff/subfolder', (err, projectDirectory) ->
      assert.ifError err
      assert.strictEqual projectDirectory, '/projects/lobal'
      done()

  it 'finds the project directory from a project subfolder via package.json', (done) ->
    mockFs
      '/projects/lobal':
        'package.json': new Buffer('1')
        'stuff':
          'subfolder':
            'subfile': new Buffer('1')

    lobal.findProjectDirectory '/projects/lobal/stuff/subfolder', (err, projectDirectory) ->
      assert.ifError err
      assert.strictEqual projectDirectory, '/projects/lobal'
      done()

  it 'gives closest directory with nested packages via node_modules', (done) ->
    mockFs
      '/projects/lobal':
        'node_modules':
          'blah': new Buffer('1')
        'stuff':
          'submodule':
            'node_modules':
              'blub': new Buffer('1')
            'suber':
              'yap': new Buffer('1')

    lobal.findProjectDirectory '/projects/lobal/stuff/submodule/suber', (err, projectDirectory) ->
      assert.ifError err
      assert.strictEqual projectDirectory, '/projects/lobal/stuff/submodule'
      done()

  it 'gives closest directory with nested packages via package.json', (done) ->
    mockFs
      '/projects/lobal':
        'package.json': new Buffer('1')
        'stuff':
          'submodule':
            'package.json': new Buffer('1')
            'suber':
              'yap': new Buffer('1')

    lobal.findProjectDirectory '/projects/lobal/stuff/submodule/suber', (err, projectDirectory) ->
      assert.ifError err
      assert.strictEqual projectDirectory, '/projects/lobal/stuff/submodule'
      done()

  it 'gives null when not in a project directory', (done) ->
    mockFs
      '/projects/lobal/stuff/subfolder':
        'subfile': new Buffer('1')

    lobal.findProjectDirectory '/projects/lobal/stuff/subfolder', (err, projectDirectory) ->
      assert.ifError err
      assert.strictEqual projectDirectory, null
      done()

  it 'gives null when in a dir that doesnt exist', (done) ->
    mockFs
      '/projects/lobal/stuff':
        'subfile': new Buffer('1')

    lobal.findProjectDirectory '/projects/lobal/stuff/subfolder', (err, projectDirectory) ->
      assert.ifError err
      assert.strictEqual projectDirectory, null
      done()

describe 'ensureSetUp', ->
  it 'creates .lobal_shims folder if it doesnt exist', (done) ->
    mockFs
      '/fakehome':
        '.bash_profile': new Buffer('')
        'hello': new Buffer('1')

    lobal.ensureSetUp ->
      exists = fs.existsSync lobal.shimsDirectory
      assert.strictEqual exists, true
      done()

  it 'appends PATH entry to .bash_profile if it isnt already there', (done) ->
    mockFsData = {}
    mockFsData[bashFile] = new Buffer('existingstuff')
    mockFs mockFsData

    lobal.ensureSetUp ->
      contents = fs.readFileSync bashFile
      assert.strictEqual contents.toString(), 'existingstuff' + lobal.bashPathEntry()
      done()

describe 'addShim', ->
  it 'adds shim', (done) ->
    mockFs
      '/fakehome/.lobal_shims':
        'hello': new Buffer('1')

    lobal.addShim 'datmodule', (err) ->
      assert.ifError err
      exists = fs.existsSync '/fakehome/.lobal_shims/datmodule'
      assert.strictEqual exists, true
      done()

  it 'gives an error if shim already exists', (done) ->
    mockFs
      '/fakehome/.lobal_shims':
        'datmodule': new Buffer('1')

    lobal.addShim 'datmodule', (err) ->
      assert.ok err
      done()

describe 'removeShim', ->
  it 'removes shim', (done) ->
    mockFs
      '/fakehome/.lobal_shims':
        'datmodule': new Buffer('1')

    lobal.removeShim 'datmodule', (err) ->
      assert.ifError err
      exists = fs.existsSync '/fakehome/.lobal_shims/datmodule'
      assert.strictEqual exists, false
      done()

  it 'gives an error if shim doesnt exist', (done) ->
    mockFs
      '/fakehome/.lobal_shims':
        'hello': new Buffer('1')

    lobal.removeShim 'datmodule', (err) ->
      assert.ok err
      done()


afterEach ->
  mockFs.restore()
