if typeof self == 'undefined'
    ulti = require './ulti.js'
    Zipper = require './Zipper.js'
    Zipper = Zipper.Zipper
else
    ulti = self.ulti
    Zipper = self.Zipper


CodeGen = (grammer, ast, indent_lex) ->
    grammer_map = GrammerParser grammer
    GenWalker(grammer_map, ast.leaves, '', indent_lex)

GenWalker = (grammer, ast_leaves, indent, indent_lex) ->
    ret = ''
    if not ast_leaves
        return ret

    for node in ast_leaves
        if node['lex'] of grammer
            ret += indent + GenCodeFromLeaves(grammer[node['lex']], node['leaves'], grammer) + '\n'
            if node['lex'] in indent_lex
                indent += '    '

        if node['leaves']
            ret += GenWalker(grammer, node['leaves'], indent, indent_lex)

    ret

GenCodeFromLeaves = (gen_order, ast_leaves, grammer) ->
    ret = ''
    if not ast_leaves
        return ret

    stratchValues = (gen_item, leaves) ->
        expand_grammer = grammer[':' + gen_item]
        for leave in leaves
            if leave.lex == gen_item
                if leave.value != undefined
                    return leave.value

                if expand_grammer
                    ret = ''
                    _selected_index = {}
                    for inner_gen_item in expand_grammer
                        if inner_gen_item.charAt(0) == '"'
                            ret += inner_gen_item.substring(1, inner_gen_item.length - 1)
                        else
                            if inner_gen_item not of _selected_index
                                _selected_index[inner_gen_item] = 0
                            else
                                _selected_index[inner_gen_item] += 1

                            selected = Zipper.select leave, inner_gen_item
                            ret += selected[_selected_index[inner_gen_item]].value

                    return ret
        gen_item

    for gen_item in gen_order
        if gen_item.charAt(0) == '"'
            ret += gen_item.substring(1, gen_item.length - 1)
        else
            ret += stratchValues(gen_item, ast_leaves)

    ret


GrammerParser = (grammer) ->
    raw_lines = grammer.split('\n')
    lines_pair = raw_lines.filter((x) -> x).map((x) -> x.replace('\\n', '\n').split('->'))
    grammer_map = {}
    for line in lines_pair
        grammer_map[line[0].trim()] = null

        gen_order = ['']
        raw_order = line[1].trim()

        l = raw_order.length
        in_string = false
        while l--
            if raw_order[l] == '"'
                if not in_string
                    in_string = true
                    gen_order[0] = '"'
                else
                    in_string = false
                    gen_order[0] = '"' + gen_order[0]
            else if raw_order[l] == '*'
                if in_string
                    gen_order[0] = raw_order[l] + gen_order[0]
            else
                if in_string
                    gen_order[0] = raw_order[l] + gen_order[0]
                else if raw_order[l] == ' '
                    if gen_order[0].length != 0
                        gen_order.unshift('')
                else
                    gen_order[0] = raw_order[l] + gen_order[0]

        grammer_map[line[0].trim()] = gen_order

    grammer_map



if typeof self == 'undefined'
    module.exports.CodeGen = CodeGen
else
    self.CodeGen = CodeGen