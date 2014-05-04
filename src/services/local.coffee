if typeof self == 'undefined'
    ulti = require './../ulti.js'
else
    ulti = self.ulti


localService = (dir_path) ->
    @dir_path = dir_path
    @

localService::generate = (parser, reparse=false) ->
    _this = @
    ulti.fileWalk(@dir_path, (file_path) ->
        fs = require 'fs'
        content = fs.readFileSync file_path
        parse_result = parser file_path, content
        for item in parse_result
            if not reparse and ulti.existLocalCache _this.type, encodeURIComponent(file_path)
                continue

            ulti.dump _this.type, encodeURIComponent(file_path), item.value
    )

localService::get = (file_path, type, cb) ->
    ulti.load type, encodeURIComponent(file_path), cb


module.exports.localService = localService

log = ->
#return
log = ulti.log