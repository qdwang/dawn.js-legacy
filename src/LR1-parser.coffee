if typeof self == 'undefined'
    ulti = require './ulti.js'
    IR = require './IR.js'
    BNFParser = require './BNF-parser.js'
    BNFGrammer = BNFParser.BNFGrammer
else
    ulti = self.ulti
    IR = self.IR
    BNFGrammer = self.BNFGrammer


SyntaxTable = (grammer_content, start_stmt, end_lex) ->
    @start_stmt = start_stmt;
    @end_lex = end_lex;

    @raw_bnf_grammer = new BNFGrammer(grammer_content)
    @raw_bnf_grammer.makePlainBNF()

    @grammer_dict = new GrammerDict(@raw_bnf_grammer.bnf_grammer_pairs)

    @live_grammers = null

    @

SyntaxTable::init = ->
    @live_grammers = {}
    for closure in @start_stmt
        @initGrammer2Live closure, @end_lex, 0

    @expand 0, null

SyntaxTable::initGrammer2Live = (closure, end_lex, expand_level) ->
    firsts_closure = []
    for reprs in (@grammer_dict.get closure)['reprs']
        if @grammer_dict.get reprs[0]
            firsts_closure.push reprs[0]

        SyntaxTable.addGrammer2Set closure, reprs, end_lex, @live_grammers, expand_level

    firsts_closure

SyntaxTable.addGrammer2Set = (closure, repr, end_lex, grammer_set, expand_level=0) ->
    repr = repr.slice()
    end_lex = end_lex.slice()

    first_lex = repr.shift()
    isOneOrMore = false

    if BNFGrammer.isOneOrMore first_lex
        first_lex = BNFGrammer.removeSpecialMark first_lex
        isOneOrMore = true

    if first_lex not of grammer_set
        grammer_set[first_lex] = []

    if isOneOrMore
        grammer_set[first_lex].repeat = true

    for each_end_lex, i in end_lex
        if BNFGrammer.isOneOrMore each_end_lex
            end_lex[i] = BNFGrammer.removeSpecialMark each_end_lex

    grammer_set[first_lex].push
        closure: closure
        repr: repr
        end_lex: end_lex
        expand_level: expand_level

SyntaxTable.mixGrammers = (a, b) ->
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

SyntaxTable.cloneGrammer = (a) ->
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
    dot_grammers = @live_grammers[dot_lex]
    log dot_lex, 'dot-lex -' + dot_lex
    if not dot_grammers
        @live_grammers = {}
        return false

    new_live_grammers = {}
    ristrict = null

    if dot_grammers.repeat
        log 'repeat!'
        new_live_grammers = SyntaxTable.cloneGrammer @live_grammers
        ristrict = [dot_lex]

    dot_grammers.sort (a, b) -> b['expand_level'] - a['expand_level']

    for each_grammer in dot_grammers
        if not each_grammer['repr'].length
            if next_lex in each_grammer['end_lex']
                return {
                    expand_level: each_grammer['expand_level'],
                    closure: each_grammer['closure']
                }
        else
            ristrict and ristrict.push BNFGrammer.removeSpecialMark each_grammer['repr'][0]
            SyntaxTable.addGrammer2Set each_grammer['closure'],
                    each_grammer['repr'],
                    each_grammer['end_lex'],
                    new_live_grammers,
                    each_grammer['expand_level']

    @live_grammers = new_live_grammers

    if dot_grammers.repeat
        for grammer of @live_grammers
            if grammer not in ristrict
                delete @live_grammers[grammer]

    @expand expand_level, ristrict

    return false

SyntaxTable::expand = (expand_level, ristrict) ->
    expanded_closures = []
    last_ec_len = 0
    if ristrict
        log ristrict, 'ristrict'

    while 1
        for closure of @live_grammers
            if ristrict and closure not in ristrict
                continue

            if @grammer_dict.get closure
                end_lex = []
                for x in @live_grammers[closure]
                    if x['repr'].length
                        first_lex = x['repr'][0]
                        first_lex = if BNFGrammer.isOneOrMore first_lex then BNFGrammer.removeSpecialMark first_lex else first_lex
                        ulti.uniqueConcat end_lex, @grammer_dict.findFirst first_lex

                    else
                        ulti.uniqueConcat end_lex, @end_lex
                        ulti.uniqueConcat end_lex, x['end_lex']


                    if @live_grammers[closure].repeat
                        ulti.uniqueConcat end_lex, @grammer_dict.findFirst closure

                    closure_id = closure + end_lex.join ''
                    if closure_id in expanded_closures
                        end_lex = []

                if not end_lex.length
                    continue

                expanded_closures.push closure_id

                firsts_closure = @initGrammer2Live closure, end_lex, expand_level
                if ristrict
                    log firsts_closure, 'firsts_closure'
                    ulti.uniqueConcat ristrict, firsts_closure

        if last_ec_len == expanded_closures.length
            break

        last_ec_len = expanded_closures.length

    null

GrammerDict = (bnf_grammer_pairs) ->
    @bnf_grammer_pairs = bnf_grammer_pairs
    @dict_map = {}

    for line in bnf_grammer_pairs
        closure = line[0]
        reprs = if line[1] instanceof Array then line[1] else [line[1]]

        if closure not of @dict_map
            @dict_map[closure] = GrammerDict.initClosure()

        for repr in reprs
            @dict_map[closure]['reprs'].push repr.split /\s+/

    @makeFirstSets()

    @

GrammerDict.initClosure = ->
    reprs: []
    first: []
    follows: []

GrammerDict::get = (closure) ->
    if BNFGrammer.isOneOrMore closure
        closure = BNFGrammer.removeSpecialMark closure

    @dict_map[closure]

GrammerDict::makeFirstSets = ->
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


GrammerDict::findFirst = (closures) ->
    if closures not instanceof Array
        closures = [closures]

    ret = []
    for closure in closures
        if closure not of @dict_map
            ulti.uniquePush ret, closure
        else
            ulti.uniqueConcat ret, @dict_map[closure]['first']

    ret


GrammerNode = (lex, parent=null, leaves=[]) ->
    @parent = null
    @leaves = leaves
    @lex = lex
    @value = null

    if parent
        @linkParent parent

    @

GrammerNode::isName = (lex) ->
    lex == @lex

GrammerNode::getValue = ->
    @value

GrammerNode::setValue = (val) ->
    @value = val

GrammerNode::appendLeaf = (leaf) ->
    if not @hasLeaf leaf
        @leaves.push leaf

GrammerNode::prependLeaf = (leaf) ->
    if not @hasLeaf leaf
        @leaves.unshift leaf

GrammerNode::hasLeaf = (leaf) ->
    leaf in @leaves

GrammerNode::findLeaf = (lex_name) ->
    for leaf in @leaves
        if leaf.lex == lex_name
            return leaf

    return null

GrammerNode::linkParent = (parent, use_prepend=null) ->
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

    @reduce_cache = {}
    @reduce_cache_len = {}

    @tree = new GrammerNode 'Syntax'

    @

SyntaxParser.flow = (args) ->
    console.log 'SyntaxParser'

    grammer = args.grammer
    start_stmt = args.start_stmt
    end_lex = args.end_lex
    sync_lex = args.sync_lex or []
    lex_list = args.lex_list
    mix_map = args.mix_map
    ast_cutter = args.ast_cutter

    SyntaxParser.Mix.mixer = ->
        mix_map.arrange.apply mix_map, arguments

    syntax_table = new SyntaxTable grammer, start_stmt, end_lex
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
        syntax_table.live_grammers = spcr.checkedLiveGrammers[cached_index]

    if not syntax_table.live_grammers
        syntax_table.init()


    len = stack.length
    stack.push lookahead

    ret = []
    for index in [cached_index + 1..len - 1]
        log syntax_table.live_grammers, 'before live grammer'

        result = syntax_table.moveDot stack[index], stack[index + 1], (index + 1)

        log result, 'after move dot'
        log syntax_table.live_grammers, 'live grammer'
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

    spcr.checkedLiveGrammers = spcr.checkedLiveGrammers.slice(0, spcr.lastCheckedStack.length)
    while spcr.checkedLiveGrammers.length < spcr.lastCheckedStack.length
        spcr.checkedLiveGrammers.push ''

    if not ret.length
        spcr.checkedLiveGrammers[spcr.checkedLiveGrammers.length - 1] = syntax_table.live_grammers

#    console.log stack
#    console.log ret
#    console.log spcr.lastCheckedStack
#    console.log spcr.checkedLiveGrammers
#    console.log ''

    if ret.length then ret else stack


SyntaxParser.checkIfReduce.lastCheckedStack = []
SyntaxParser.checkIfReduce.checkedLiveGrammers = []
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

    syntax_table.live_grammers = null
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
        new_gt = new GrammerNode curr_stack[curr_len - 1], @tree

    else
        for i in [0..curr_len - 1]
            if not @tree.leaves[i].isName curr_stack[i]
                break

        new_gt = new GrammerNode curr_stack[curr_len - 1]

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