if typeof self == 'undefined'
    ulti = require './ulti.js'
else
    ulti = self.ulti


MixMap  = ->
    @i = 1
    @ref_map = {}
    @


MixMap::arrange = -> # [type, object], [type, object] ...
    self = @
    pairs2map = [].slice.call arguments
    pairs_len = pairs2map.length
    if pairs_len < 2
        return null

    apply_mapping =  (_pairs2map) ->
        obj_type = _pairs2map[0][0]
        obj = _pairs2map[0][1]

        mm_id = obj['__MixMapID__'] or self.i++
        if not obj['__MixMapID__']
            obj['__MixMapID__'] = mm_id

        if not self.ref_map[mm_id]
            self.ref_map[mm_id] = {}

        for i in [1.._pairs2map.length - 1]
            ref = _pairs2map[i]
            self.ref_map[mm_id][ref[0]] = ref[1]


    additional_pairs_main = []
    additional_pairs_attach = []
    for pair in pairs2map
        inner_map = @.get pair[1]

        if not inner_map
            additional_pairs_main.push pair

        for key of inner_map
            additional_pairs_attach.push [key, inner_map[key]]

    for i in additional_pairs_main
        for m in additional_pairs_attach
            apply_mapping [i, m]
            apply_mapping [m, i]


    for i in [0..pairs_len - 1]
        if i != 0 and pairs2map[0][1] == pairs2map[i][1]
            continue

        swaper = pairs2map[i]
        pairs2map[i] = pairs2map[0]
        pairs2map[0] = swaper

        apply_mapping pairs2map


MixMap::get = (obj, type) ->
    if typeof obj != 'object' or not obj['__MixMapID__']
        return null

    ref = @ref_map[obj['__MixMapID__']]

    if not ref
        return null

    if type then ref[type] else ref


if typeof self == 'undefined'
    module.exports.MixMap = MixMap
else
    self.MixMap = MixMap

log = ->
#return
log = ulti.log