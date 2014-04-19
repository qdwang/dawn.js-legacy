if typeof self == 'undefined'
    ulti = require './ulti.js'
    IR = require './IR.js'
else
    ulti = self.ulti
    IR = self.IR


SymbolTable = (markers) ->
    @markers = markers # {'Receiver': fn, 'Giver': fn, 'Assignment': null}
    @stack = [] # [{'Receiver': X, 'Giver': Y, 'Assignment': {Z}}]
    @parent = null
    @

SymbolTable.flow = (args) ->
    console.log 'SymbolTable'

    ast = args.ast
    markers = args.markers
    scope_rules = args.scope_rules
    mix_map = args.mix_map

    SymbolTable.Mix.mixer = ->
        mix_map.arrange.apply mix_map, arguments

    symbol_tables = SymbolTable.walkGenerate ast, markers, scope_rules

    args.symbol_tables = symbol_tables

    SymbolTable.Mix.mixer = null


SymbolTable::convert = (obj) ->
    obj_empty = true
    for i of obj
        obj_empty = false
        if i of @markers and @markers[i] != null and typeof obj[i] == 'object'
            obj[i] = @markers[i] obj[i]

    obj_empty

SymbolTable.match = (record, cond_obj) ->
    for cond of cond_obj
        if record[cond] != cond_obj[cond]
            return false

    true

SymbolTable::push = (obj) ->
    is_obj_empty = @convert obj

    if not is_obj_empty
        @stack.push obj

SymbolTable::concat = ->
    arg_arr = [].slice.call arguments
    for obj in arg_arr
        @push obj


SymbolTable::lookUpTop = (cond_obj) ->
    is_obj_empty = @convert cond_obj

    if is_obj_empty
        return null

    found = false
    for l in [@stack.length - 1..0]
        record = @stack[l]
        if SymbolTable.match record, cond_obj
            found = record
            break

    if found
        return found

    if not found and @parent
        return @parent.lookUpTop cond_obj
    else
        return null


SymbolTable::filter = (filter_method, scope_mode=0) ->
    ###
        scope_mode:
            0 -> only lookup current scope,
            1 -> will lookup parent scope if no matches in current scope,
            2 -> matches in all scopes
    ###

    ret = []
    for record in @stack
        if filter_method record
            ret.push record

    if scope_mode == 1 and not ret.length and @.parent
        ret = ret.concat @.parent.filter filter_method, 1

    else if scope_mode == 2 and @.parent
        ret = ret.concat @.parent.filter filter_method, 2

    ret



SymbolTable.walkGenerate = (ast, markers, scope_rules) ->
    ret = []

    store_record = (obj, stored) ->
        new_records_len = stored.length
        for key of obj # the only one key is node.lex
            if key of stored[new_records_len - 1]
                stored.push obj
            else
                stored[new_records_len - 1][key] = obj[key]


    walk = (node, curr_scope_table, stored, reduce_result) ->
        parse_leaves = true

        if node.lex in scope_rules
            new_scope_table = new SymbolTable markers
            new_scope_table.parent = curr_scope_table

            curr_scope_table = new_scope_table
            stored = [{}]
            reduce_result = true

        if node.lex of markers
            record_obj = {}
            record_obj[node.lex] = node
            store_record record_obj, stored

            parse_leaves = false

        if node.leaves
            for leaf in node.leaves
                walk leaf, curr_scope_table, stored, false

        if reduce_result
            ret.push curr_scope_table
            SymbolTable.Mix ['SyntaxNode', node], ['SymbolTable', curr_scope_table]

            while obj = stored.shift()
                curr_scope_table.push obj

    walk ast, (new SymbolTable markers), [{}], true
    ret


SymbolTable.Mix = ->
    if not SymbolTable.Mix.mixer
        return null

    SymbolTable.Mix.mixer.apply @, arguments



if typeof self == 'undefined'
    module.exports.SymbolTable = SymbolTable
else
    self.SymbolTable = SymbolTable


log = ->
#return
log = ulti.log