if typeof self == 'undefined'
    util = require './util.js'
else
    util = self.util


BNFGrammar = (bnf_raw_content) ->
    @raw_bnf_grammar = bnf_raw_content

    grammar_lines = bnf_raw_content.split '\n'
    grammar_lines_arr = @grammarPrepare grammar_lines
#    grammar_lines_arr = (((if x and x.match /\|/ then (y.trim() for y in x.split '|') else x.trim()) for x in line.split '->') for line in grammar_lines)

#    @dist = grammar_lines_arr[0][0]
    @bnf_grammar_pairs = grammar_lines_arr

    @

BNFGrammar::grammarPrepare = (grammar_lines) ->
    ret = []

    repr_walker = (repr) ->
        repr_arr = ['']
        can_split = true

        for char in repr
            if char == '(' or char == '['
                can_split = false
            else if char == ')' or char == ']'
                can_split = true

            if char == '|' and can_split
                repr_arr.push ''
            else
                repr_arr[repr_arr.length - 1] += char

        (repr.trim() for repr in repr_arr)


    for line in grammar_lines
        production = []
        line_arr = line.split '->'
        production.push line_arr[0].trim()
        production.push repr_walker line_arr[1]
        ret.push production

    ret




BNFGrammar.isOneOrMore = (closure) ->
    closure.length > 1 and '+' == closure.slice -1


BNFGrammar.removeSpecialMark = (closure) ->
    closure.replace /[\[\]\(\)\*\+]+/g, ''

BNFGrammar.hasSpecialMark = (closure) ->
    closure.match /[\[\]\(\)\*\+]+/


BNFGrammar::makePlainBNF = (stop) ->
    rules =
        group: /[\(\[][^\s].+?[^\s][\)\]]/g

    expandBNF = (repr) ->
        ret = e: [], reprs: []

        if matched_lex = repr.match rules.group
            for each_lex in matched_lex
                e_suffix = (new Date).getTime() + Math.random()
                E = 'E!' + e_suffix.toString 36
                E = E.replace '.', ''

                repr = repr.replace each_lex, if each_lex[0] == '[' then '[' + E + ']' else E

                each_lex = each_lex.replace /\(|\)|\[|\]/g, ''
                each_lex_arr = (x.trim() for x in each_lex.split '|')

                ret.e.push [E, each_lex_arr]

        lexes = repr.split /\s+/
        for lex, i in lexes
            if lex.length > 1 and '*' == lex.slice -1
                lexes[i] = ['', (lex.slice 0, -1) + '+']
            else if lex[0] == '['
                lexes[i] = ['', lex.slice 1, -1]
            else
                lexes[i] = [lex]

        ret.reprs = util.stripEmptyOfList util.makeCombination lexes
        ret.reprs = ret.reprs.map (x) -> x.join ' '

        ret

    additional_reprs = []
    for pairs in @bnf_grammar_pairs
        if pairs[1] not instanceof Array
            pairs[1] = [pairs[1]]

        expanded_reprs = []
        for repr in pairs[1]
            new_bnf = expandBNF repr

            if new_bnf.e.length
                additional_reprs = additional_reprs.concat new_bnf.e

            expanded_reprs = expanded_reprs.concat new_bnf.reprs

        pairs[1] = expanded_reprs


    for repr in additional_reprs
        @bnf_grammar_pairs.push repr

    if not stop
        @makePlainBNF(1)


if typeof self == 'undefined'
    module.exports.BNFGrammar = BNFGrammar
else
    self.BNFGrammar = BNFGrammar

log = ->
#return
log = util.log