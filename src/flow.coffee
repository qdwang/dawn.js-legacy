Flow = (start_arguments = {}) ->
    @funcs = []
    @args = start_arguments
    @

Flow::append = (fn) ->
    @funcs = @funcs.concat fn
    @

Flow::finish = ->
    while @.next()
        1

    @

Flow::next = ->
    if not @funcs.length
        return null

    fn = @funcs.shift()
    fn @args
    @

Flow::result = (filter_arg) ->
    if typeof filter_arg == 'string'
        return @args[filter_arg]

    ret = {}
    for i of filter_arg
        ret[i] = @args[i]

    ret

if typeof self == 'undefined'
    module.exports.Flow = Flow
else
    self.Flow = Flow