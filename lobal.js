#!/usr/bin/env node

var fs = require('fs')
var path = require('path')

var findup = require('findup')

function readJson (file, cb) {
  fs.readFile(file, function (err, contents) {
    if (err) return cb(err)
    cb(null, JSON.parse(contents.toString()))
  })
}

exports.packageVersion = function (packageName, dir, cb) {
  findup(dir, 'node_modules', function (err, projectRoot) {
    if (err) return cb(err)

    readJson(path.join(projectRoot, 'node_modules', packageName, 'package.json'), function (err, pkg) {
      if (err) return cb(err)
      cb(null, pkg.version)
    })
  })
}

