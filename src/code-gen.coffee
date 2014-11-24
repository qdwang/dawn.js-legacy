if typeof self == 'undefined'
    ulti = require './ulti.js'
    Zipper = require './Zipper.js'
    Zipper = Zipper.Zipper
else
    ulti = self.ulti
    Zipper = self.Zipper


CodeGen = (grammar, ast, indent_lex) ->
    grammar_map = grammarParser grammar
    GenWalker(grammar_map, ast.leaves, '', indent_lex)

GenWalker = (grammar, ast_leaves, indent, indent_lex) ->
    ret = ''
    if not ast_leaves
        return ret

    for node in ast_leaves
        if node['lex'] of grammar
            ret += indent + GenCodeFromLeaves(grammar[node['lex']], node['leaves'], grammar) + '\n'
            if node['lex'] in indent_lex
                indent += '    '

        if node['leaves']
            ret += GenWalker(grammar, node['leaves'], indent, indent_lex)

    ret

GenCodeFromLeaves = (gen_order, ast_leaves, grammar) ->
    ret = ''
    if not ast_leaves
        return ret

    stratchValues = (gen_item, leaves) ->
        expand_grammar = grammar[':' + gen_item]
        for leave in leaves
            if leave.lex == gen_item
                if leave.value != undefined
                    return leave.value

                if expand_grammar
                    ret = ''
                    _selected_index = {}
                    for inner_gen_item in expand_grammar
                        if not inner_gen_item
                            continue

                        if inner_gen_item instanceof Array
                            none_or_more_item_find = true
                            while none_or_more_item_find
                                none_or_more_set = ''
                                for none_or_more_item in inner_gen_item
                                    if none_or_more_item.charAt(0) == '"' and none_or_more_item.charAt(none_or_more_item.length - 1) == '"'
                                        none_or_more_set += none_or_more_item.substring(1, none_or_more_item.length - 1)
                                    else
                                        if none_or_more_item not of _selected_index
                                            _selected_index[none_or_more_item] = 0
                                        else
                                            _selected_index[none_or_more_item] += 1

                                        selected = Zipper.select leave, none_or_more_item
                                        if selected[_selected_index[none_or_more_item]]
                                            none_or_more_set += selected[_selected_index[none_or_more_item]].value
                                        else
                                            none_or_more_item_find = false
                                            break

                                if not none_or_more_item_find
                                    break
                                else
                                    ret += none_or_more_set

                        else if inner_gen_item.charAt(0) == '"' and inner_gen_item.charAt(inner_gen_item.length - 1) == '"'
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


grammarParser = (grammar) ->
    raw_lines = grammar.split('\n')
    lines_pair = raw_lines.filter((x) -> x).map((x) -> x.replace('\\n', '\n').split('->'))
    grammar_map = {}
    for line in lines_pair
        grammar_map[line[0].trim()] = null

        gen_order = ['']
        raw_order = line[1].trim()

        l = raw_order.length
        in_string = false
        add_zero_or_more = 0   # 0: No 1: One item 2: Group item
        asterisk_order = ['']
        while l--
            if raw_order[l] == '"'
                if not in_string
                    in_string = true
                    if add_zero_or_more == 0
                        gen_order[0] = '"'
                    else
                        asterisk_order[0] = '"'
                else
                    in_string = false
                    if add_zero_or_more == 0
                        gen_order[0] = '"' + gen_order[0]
                    else
                        asterisk_order[0] = '"' + asterisk_order[0]

            else if raw_order[l] == '*'
                if in_string
                    gen_order[0] = raw_order[l] + gen_order[0]
                else
                    add_zero_or_more = if raw_order[l - 1] == ')' then 2 else 1
                    if add_zero_or_more == 2
                        l--
            else
                if in_string
                    if add_zero_or_more == 0
                        gen_order[0] = raw_order[l] + gen_order[0]
                    else
                        asterisk_order[0] = raw_order[l] + asterisk_order[0]

                else if raw_order[l] == ' '
                    if add_zero_or_more != 0
                        if add_zero_or_more == 1
                            add_zero_or_more = 0
                            gen_order.unshift(asterisk_order)
                            gen_order.unshift('')
                            asterisk_order = ['']
                        else
                            asterisk_order.unshift('')

                    else if gen_order[0].length != 0
                        gen_order.unshift('')

                else if raw_order[l] == '(' and add_zero_or_more == 2
                    add_zero_or_more = 0
                    gen_order.unshift(asterisk_order)
                    asterisk_order = ['']
                else
                    if add_zero_or_more != 0
                        asterisk_order[0] = raw_order[l] + asterisk_order[0]
                    else
                        gen_order[0] = raw_order[l] + gen_order[0]

        grammar_map[line[0].trim()] = gen_order

    grammar_map



if typeof self == 'undefined'
    module.exports.CodeGen = CodeGen
else
    self.CodeGen = CodeGen