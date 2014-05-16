if typeof self == 'undefined'
    ulti = require './../ulti.js'
else
    ulti = self.ulti


localService = (dir_path) ->
    @dir_path = dir_path
    @

localService::generate = (parser, only=[], reparse=false) ->
    _this = @
    ulti.fileWalk(@dir_path, (file_path) ->
        for o in only
            if o != file_path.slice(-3)
                return false

        fs = require 'fs'
        content = fs.readFileSync file_path
        parse_result = parser file_path, content.toString()
        for item in parse_result
            if not reparse and ulti.existLocalCache item.type, encodeURIComponent(file_path)
                continue

            ulti.dump item.type, encodeURIComponent(file_path), item.value
    )

localService::get = (file_path, type, callback) ->
    ulti.load type, encodeURIComponent(file_path), callback


module.exports.localService = localService

log = ->
#return
log = ulti.log