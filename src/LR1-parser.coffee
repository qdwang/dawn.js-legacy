if typeof self == 'undefined'
    ulti = require './ulti.js'
    IR = require './IR.js'
    BNFParser = require './BNF-parser.js'
    BNFGrammar = BNFParser.BNFGrammar
else
    ulti = self.ulti
    IR = self.IR
    BNFGrammar = self.BNFGrammar


SyntaxTable = (grammar_content, start_stmt, end_lex) ->
    @start_stmt = start_stmt;
    @end_lex = end_lex;

    @raw_bnf_grammar = new BNFGrammar(grammar_content)
    @raw_bnf_grammar.makePlainBNF()

    @grammar_dict = new GrammarDict(@raw_bnf_grammar.bnf_grammar_pairs)

    @live_grammars = null

    @

SyntaxTable::init = ->
    @live_grammars = {}
    for closure in @start_stmt
        @initGrammar2Live closure, @end_lex, 0

    @expand 0, null

SyntaxTable::initGrammar2Live = (closure, end_lex, expand_level) ->
    firsts_closure = []
    for reprs in (@grammar_dict.get closure)['reprs']
        if @grammar_dict.get reprs[0]
            firsts_closure.push reprs[0]

        SyntaxTable.addGrammar2Set closure, reprs, end_lex, @live_grammars, expand_level

    firsts_closure

SyntaxTable.addGrammar2Set = (closure, repr, end_lex, grammar_set, expand_level=0) ->
    repr = repr.slice()
    end_lex = end_lex.slice()

    first_lex = repr.shift()
    isOneOrMore = false

    if BNFGrammar.isOneOrMore first_lex
        first_lex = BNFGrammar.removeSpecialMark first_lex
        isOneOrMore = true

    if first_lex not of grammar_set
        grammar_set[first_lex] = []

    if isOneOrMore
        grammar_set[first_lex].repeat = true

    for each_end_lex, i in end_lex
        if BNFGrammar.isOneOrMore each_end_lex
            end_lex[i] = BNFGrammar.removeSpecialMark each_end_lex

    grammar_set[first_lex].push
        closure: closure
        repr: repr
        end_lex: end_lex
        expand_level: expand_level

SyntaxTable.mixGrammars = (a, b) ->
    ret = {}
    for i of a
        if i not of ret
            ret[i] = []

        ret[i] = ret[i].concat a[i]

    for i of b
        if i not of ret
            ret[i] = []

        ret[i] = ret[i].concat b[i]

    log a, 'mix from a'
    log b, 'mix from b'
    log ret, 'mixed'
    ret

SyntaxTable.cloneGrammar = (a) ->
    ret = {}
    for closure of a
        ret[closure] = []
        if a[closure].repeat
            ret[closure].repeat = true

        for unit in a[closure]
            item =
                closure: unit['closure']
                repr: unit['repr']
                end_lex: unit['end_lex']
                expand_level: unit['expand_level']

            ret[closure].push item

    ret

SyntaxTable::moveDot = (dot_lex, next_lex, expand_level) ->
    dot_grammars = @live_grammars[dot_lex]
    log dot_lex, 'dot-lex -' + dot_lex
    if not dot_grammars
        @live_grammars = {}
        return false

    new_live_grammars = {}
    ristrict = null

    if dot_grammars.repeat
        log 'repeat!'
        new_live_grammars = SyntaxTable.cloneGrammar @live_grammars
        ristrict = [dot_lex]

    dot_grammars.sort (a, b) -> b['expand_level'] - a['expand_level']

    for each_grammar in dot_grammars
        if not each_grammar['repr'].length
            if next_lex in each_grammar['end_lex']
                return {
                    expand_level: each_grammar['expand_level'],
                    closure: each_grammar['closure']
                }
        else
            ristrict and ristrict.push BNFGrammar.removeSpecialMark each_grammar['repr'][0]
            SyntaxTable.addGrammar2Set each_grammar['closure'],
                    each_grammar['repr'],
                    each_grammar['end_lex'],
                    new_live_grammars,
                    each_grammar['expand_level']

    @live_grammars = new_live_grammars

    if dot_grammars.repeat
        for grammar of @live_grammars
            if grammar not in ristrict
                delete @live_grammars[grammar]

    @expand expand_level, ristrict

    return false

SyntaxTable::expand = (expand_level, ristrict) ->
    expanded_closures = []
    last_ec_len = 0
    if ristrict
        log ristrict, 'ristrict'

    while 1
        for closure of @live_grammars
            if ristrict and closure not in ristrict
                continue

            if @grammar_dict.get closure
                end_lex = []
                for x in @live_grammars[closure]
                    if x['repr'].length
                        first_lex = x['repr'][0]
                        first_lex = if BNFGrammar.isOneOrMore first_lex then BNFGrammar.removeSpecialMark first_lex else first_lex
                        ulti.uniqueConcat end_lex, @grammar_dict.findFirst first_lex

                    else
                        ulti.uniqueConcat end_lex, @end_lex
                        ulti.uniqueConcat end_lex, x['end_lex']


                    if @live_grammars[closure].repeat
                        ulti.uniqueConcat end_lex, @grammar_dict.findFirst closure

                    closure_id = closure + end_lex.join ''
                    if closure_id in expanded_closures
                        end_lex = []

                if not end_lex.length
                    continue

                expanded_closures.push closure_id

                firsts_closure = @initGrammar2Live closure, end_lex, expand_level
                if ristrict
                    log firsts_closure, 'firsts_closure'
                    ulti.uniqueConcat ristrict, firsts_closure

        if last_ec_len == expanded_closures.length
            break

        last_ec_len = expanded_closures.length

    null

GrammarDict = (bnf_grammar_pairs) ->
    @bnf_grammar_pairs = bnf_grammar_pairs
    @dict_map = {}

    for line in bnf_grammar_pairs
        closure = line[0]
        reprs = if line[1] instanceof Array then line[1] else [line[1]]

        if closure not of @dict_map
            @dict_map[closure] = GrammarDict.initClosure()

        for repr in reprs
            @dict_map[closure]['reprs'].push repr.split /\s+/

    @makeFirstSets()

    @

GrammarDict.initClosure = ->
    reprs: []
    first: []
    follows: []

GrammarDict::get = (closure) ->
    if BNFGrammar.isOneOrMore closure
        closure = BNFGrammar.removeSpecialMark closure

    @dict_map[closure]

GrammarDict::makeFirstSets = ->
    getFirst = (closure_key, first_set, pushed_closures) ->
        closure = @dict_map[closure_key]
        pushed_closures.push closure_key

        for repr in closure['reprs']
            if repr[0] in pushed_closures
                continue

            if repr[0] of @dict_map
                getFirst.call @, repr[0], first_set, pushed_closures
            else
                ulti.uniquePush first_set, repr[0]

    for closure_key of @dict_map
        closure = @dict_map[closure_key]
        first_set = closure['first']
        getFirst.call @, closure_key, first_set, []


GrammarDict::findFirst = (closures) ->
    if closures not instanceof Array
        closures = [closures]

    ret = []
    for closure in closures
        if closure not of @dict_map
            ulti.uniquePush ret, closure
        else
            ulti.uniqueConcat ret, @dict_map[closure]['first']

    ret


GrammarNode = (lex, parent=null, leaves=[]) ->
    @parent = null
    @leaves = leaves
    @lex = lex
    @value = null

    if parent
        @linkParent parent

    @

GrammarNode::isName = (lex) ->
    lex == @lex

GrammarNode::getValue = ->
    @value

GrammarNode::setValue = (val) ->
    @value = val

GrammarNode::appendLeaf = (leaf) ->
    if not @hasLeaf leaf
        @leaves.push leaf

GrammarNode::prependLeaf = (leaf) ->
    if not @hasLeaf leaf
        @leaves.unshift leaf

GrammarNode::hasLeaf = (leaf) ->
    leaf in @leaves

GrammarNode::findLeaf = (lex_name) ->
    for leaf in @leaves
        if leaf.lex == lex_name
            return leaf

    return null

GrammarNode::linkParent = (parent, use_prepend=null) ->
    @parent = parent

    if use_prepend
        parent.prependLeaf @
    else
        parent.appendLeaf @


AST = (syntax_tree, patterns=[]) ->
    @syntax_tree = syntax_tree
    @patterns = patterns

    AST.cutLeaves @syntax_tree, @patterns

    @

AST.cutLeaves = (syntax_tree, patterns) ->
    walk = (node) ->
        for leaf in node.leaves
            walk leaf

        if node.lex in patterns or (node.lex.slice(0, 2) == 'E!' and node.value == null)
            new_parent_leaves = []
            for neighbor in node.parent.leaves
                if neighbor == node
                    new_parent_leaves = new_parent_leaves.concat node.leaves
                    for leaf in node.leaves
                        leaf.parent = node.parent
                else
                    new_parent_leaves = new_parent_leaves.concat neighbor

            node.parent.leaves = new_parent_leaves

        if not node.leaves.length
            delete node.leaves
        if node.value == null
            delete node.value

    walk syntax_tree

SyntaxParser = (input_lex) ->
    @raw_input_lex = input_lex
    @input_lex = input_lex.map (x) -> if x instanceof Array then x[0] else x
    @input_val = input_lex.map (x) -> if x instanceof Array then x[1] else null
    @stack = []

    @sync_lex = []

    @_reduce_cache = {}
    @_reduce_cache_len = {}

    @tree = new GrammarNode 'Syntax'

    @

SyntaxParser.flow = (args) ->
    console.log 'SyntaxParser'

    grammar = args.grammar
    start_stmt = args.start_stmt
    end_lex = args.end_lex
    sync_lex = args.sync_lex or []
    lex_list = args.lex_list
    mix_map = args.mix_map
    ast_cutter = args.ast_cutter

    SyntaxParser.Mix.mixer = ->
        mix_map.arrange.apply mix_map, arguments

    syntax_table = new SyntaxTable grammar, start_stmt, end_lex
    syntax_parser = new SyntaxParser lex_list
    syntax_parser.sync_lex = sync_lex
    
    syntax_parser.parseTable syntax_table

    ast = syntax_parser.getAST ast_cutter

    args.ast = ast.syntax_tree

    SyntaxParser.Mix.mixer = null


SyntaxParser::getAST = (patterns) ->
    new AST @tree, patterns

SyntaxParser::shift = ->
    if @input_lex.length
        @stack.push @input_lex.shift()
    else
        return false

SyntaxParser.checkIfReduce = (syntax_table, stack, lookahead) ->
    spcr = SyntaxParser.checkIfReduce

    cached_index = spcr.getCachedIndex stack
    if cached_index > -1
        syntax_table.live_grammars = spcr.checkedLiveGrammars[cached_index]

    if not syntax_table.live_grammars
        syntax_table.init()


    len = stack.length
    stack.push lookahead

    ret = []
    for index in [cached_index + 1..len - 1]
        log syntax_table.live_grammars, 'before live grammar'

        result = syntax_table.moveDot stack[index], stack[index + 1], (index + 1)

        log result, 'after move dot'
        log syntax_table.live_grammars, 'live grammar'
        log index + 1, 'move dot index'
        if result
            ret = stack.slice 0, result['expand_level']
            ret.push result['closure']

    stack.pop()

    if ret.length
        spcr.lastCheckedStack = ret.slice 0, -1
#        spcr.lastCheckedStack = []
    else
        spcr.lastCheckedStack = stack.slice()

    spcr.checkedLiveGrammars = spcr.checkedLiveGrammars.slice(0, spcr.lastCheckedStack.length)
    while spcr.checkedLiveGrammars.length < spcr.lastCheckedStack.length
        spcr.checkedLiveGrammars.push ''

    if not ret.length
        spcr.checkedLiveGrammars[spcr.checkedLiveGrammars.length - 1] = syntax_table.live_grammars

#    console.log stack
#    console.log ret
#    console.log spcr.lastCheckedStack
#    console.log spcr.checkedLiveGrammars
#    console.log ''

    if ret.length then ret else stack


SyntaxParser.checkIfReduce.lastCheckedStack = []
SyntaxParser.checkIfReduce.checkedLiveGrammars = []
SyntaxParser.checkIfReduce.getCachedIndex = (stack) ->
    scif = SyntaxParser.checkIfReduce

    for item, index in stack
        if scif.lastCheckedStack[index] != item
            index--
            break

    if index == stack.length then index - 1 else index



# Not For Use
SyntaxParser::multiReverseReduce = (syntax_table) ->
    for i in [1..@stack.length]
        syntax_table.init()
        result = SyntaxParser.checkIfReduce syntax_table, (@stack.slice -i), @input_lex[0]

        if result
            @stack = @stack.slice 0, (@stack.length - i)
            @stack.push result
            if i > 1
                @reduce syntax_table
                break

# Not For Use
SyntaxParser::MultiReduce = (syntax_table) ->
    for i in [0..@stack.length - 1]
        syntax_table.init()

        result = SyntaxParser.checkIfReduce syntax_table, (@stack.slice i, @stack.length), @input_lex[0]
        if result
            @stack = @stack.slice 0, i
            @stack.push result

            @reduce syntax_table
            break

SyntaxParser::reduce = (syntax_table, value_assign=true) ->
    log @stack, 'before reduce'
    @generateTree(value_assign)

    syntax_table.live_grammars = null
    result = SyntaxParser.checkIfReduce syntax_table, @stack, @input_lex[0]

    sync_index = @sync_lex.indexOf result[result.length - 1]
    sync_len = @sync_lex.length

    if sync_index > -1 and sync_index != sync_len - 1 and @stack == result
        last_stmt_index = result.lastIndexOf @sync_lex[@sync_lex.length - 1]
        result = result.slice(0, last_stmt_index + 1).concat @sync_lex[sync_index + 1]

    if result
        stack_changed = @stack != result
        value_assign = if result.length > @stack.length then true else false

        if stack_changed
            @stack = result
            @reduce syntax_table, value_assign


SyntaxParser::generateTree = (value_assign) ->
    curr_stack = @stack.slice()
    curr_len = curr_stack.length
    curr_node_leaves_len = @tree.leaves.length

    if curr_len > curr_node_leaves_len
        new_gt = new GrammarNode curr_stack[curr_len - 1], @tree

    else
        for i in [0..curr_len - 1]
            if not @tree.leaves[i].isName curr_stack[i]
                break

        new_gt = new GrammarNode curr_stack[curr_len - 1]

        while i++ != curr_node_leaves_len
            @tree.leaves.pop().linkParent new_gt, true

        new_gt.linkParent @tree

    if value_assign
        SyntaxParser.Mix ['SyntaxNode', new_gt], ['Lex', @raw_input_lex[@raw_input_lex.length - @input_val.length]]
        new_gt.value = @input_val.shift()

SyntaxParser::parseTable = (syntax_table) ->
    len = @.input_lex.length - 1
    for i in [1..len]
        @.shift syntax_table
        log @.stack, 'before reduce'
        @.reduce syntax_table
        log @.stack, 'after reduce'


SyntaxParser.Mix = ->
    if not SyntaxParser.Mix.mixer
        return null

    SyntaxParser.Mix.mixer.apply @, arguments


if typeof self == 'undefined'
    module.exports.SyntaxTable = SyntaxTable
    module.exports.SyntaxParser = SyntaxParser
    module.exports.AST = AST
else
    self.SyntaxTable = SyntaxTable
    self.SyntaxParser = SyntaxParser
    self.AST = AST


log = ->
return
log = ulti.log