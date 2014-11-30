if typeof self == 'undefined'
    util = require './util.js'
else
    util = self.util

LexParser = (script, syntax) ->
    @script = script

    @lex_syntax = syntax
    @lex_list = []

    @cursor_lex = null

    @

LexParser.flow = (args) ->
    console.log 'LexParser'

    script = args.script
    lex_syntax = args.lex_syntax
    cursor_pos = args.cursor_pos
    make_dedent = args.make_dedent

    lp = new LexParser script, lex_syntax
    lp.tokenize cursor_pos
    if make_dedent
        lp.makeDedent make_dedent

    lp.lex_list.push 'ProgramEnd'


    args.lex_list = lp.lex_list
    args.cursor_lex = lp.cursor_lex
    args.end_lex = ['ProgramEnd']

LexParser::tokenize = (cursor_pos) ->
    lex_obj = {}

    script_arr = [@script]
    for syntax_name of @lex_syntax
        offset = 0
        new_script_arr = []

        for unit in script_arr
            if typeof unit == 'number'
                offset += unit
                new_script_arr.push unit
            else
                str = unit
                unit_arr = []

                while match = @lex_syntax[syntax_name].exec str
                    offset += match.index

                    match_lex_len = match[0].length
                    lex = [syntax_name, match[0]]
                    lex_obj[offset] = lex

                    if not @cursor_lex and cursor_pos and cursor_pos > offset and cursor_pos <= offset + match_lex_len
                        @cursor_lex = lex

                    prefix = str.slice(0, match.index)

                    if not prefix.trim() then unit_arr.push prefix.length else unit_arr.push prefix
                    unit_arr.push match_lex_len

                    str = str.slice(match.index + match_lex_len)
                    offset += match_lex_len

                if not str.trim() then unit_arr.push str.length else unit_arr.push str

                offset += str.length

                new_script_arr = new_script_arr.concat unit_arr

        script_arr = new_script_arr

    for lex of lex_obj
        @lex_list.push lex_obj[lex]

    @

LexParser::makeDedent = (base_lex = 'Indent', insert_lex = 'Dedent') ->
    new_lex_list = []

    last_indent = 0
    mixed_indent = 0
    for lex in @lex_list
        if lex[1] == '\n'
            mixed_indent = 0
            new_lex_list.push lex
        else if lex[0] == base_lex
            mixed_indent += 1
        else
            if new_lex_list.length and new_lex_list[new_lex_list.length - 1][1] == '\n'
                if mixed_indent < last_indent
                    for i in [0..last_indent - mixed_indent - 1]
                        new_lex_list.push [insert_lex, '    ']
                if mixed_indent > 0
                    new_lex_list.push [base_lex, '    ']

                last_indent = mixed_indent

            new_lex_list.push lex

    if last_indent > 0
        new_lex_list.push [insert_lex, '    ']

    @.lex_list = new_lex_list
    @

LexParser.rebuild = (lex_list, mix_map) ->
    for lex_pair in lex_list
        if lex_pair['__MixMapID__']
            mix_map.refs[lex_pair['__MixMapID__']] = lex_pair


if typeof self == 'undefined'
    module.exports.LexParser = LexParser
else
    self.LexParser = LexParser

log = ->
#return
log = util.log
