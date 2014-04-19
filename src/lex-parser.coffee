if typeof self == 'undefined'
    ulti = require './ulti.js'
else
    ulti = self.ulti

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

    lp = new LexParser script, lex_syntax
    lp.tokenize cursor_pos
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


if typeof self == 'undefined'
    module.exports.LexParser = LexParser
else
    self.LexParser = LexParser

log = ->
#return
log = ulti.log
