BNF = require './../src/BNF-parser.js'
Lexer = require './../src/lex-parser.js'
LR1 = require './../src/LR1-parser.js'
Zipper = require './../src/Zipper.js'
IR = require './../src/IR.js'
SymbolTable = require './../src/symbol-table.js'
ulti = require './../src/ulti.js'

log = ulti.log
stringEqual = ulti.stringEqual


### Ulti ###
sample_obj = {S: {E: ['a', 'b', 'c', 'd'], A: {B: 5}}, C: 'foo'}
log (ulti.objDotAccessor sample_obj, 'S.E.0') == 'a', 'objDotAccessor 1'
log (ulti.objDotAccessor sample_obj, 'C') == 'foo', 'objDotAccessor 2'
log (ulti.objDotAccessor sample_obj, 'S.A.B') == 5, 'objDotAccessor 3'
log (ulti.objDotAccessor sample_obj, 'S.E.2') == 'c', 'objDotAccessor 4'


### BNF ###

G = """
S -> E
E -> [b g] (A g)* A (B x)* | A A+ B | A d+ B | B (, opt)* | A [b g] [b g] | (A | B | d C*)+ | B [A | c]
A -> a b
B -> b
B -> A | ( A + A )
A -> B * B
A -> c
"""

bnf = new BNF.BNFGrammar G
bnf.makePlainBNF()

#log bnf.bnf_grammar_pairs, 'BNF', 4
stringEqual bnf.bnf_grammar_pairs, """
[["S",["E"]],["E",["A","A E!htp2inec+","E!htbz8sdr+ A","E!htbz8sdr+ A E!htp2inec+","E!ht1ife46 A","E!ht1ife46 A E!htp2inec+","E!ht1ife46 E!htbz8sdr+ A","E!ht1ife46 E!htbz8sdr+ A E!htp2inec+","A A+ B","A d+ B","B","B E!hu0sbrr7+","A","A E!ht62uakw","A E!htlus4sf","A E!htlus4sf E!ht62uakw","E!htvwq2yz+","B","B E!httrpl8n"]],["A",["a b"]],["B",["b"]],["B",["A","( A + A )"]],["A",["B * B"]],["A",["c"]],["E!ht1ife46",["b g"]],["E!htbz8sdr",["A g"]],["E!htp2inec",["B x"]],["E!hu0sbrr7",[", opt"]],["E!htlus4sf",["b g"]],["E!ht62uakw",["b g"]],["E!htvwq2yz",["A","B","d","d C+"]],["E!httrpl8n",["A","c"]]]
""", 'BNF'


### Lexer ###
prepare_syntax =
    'NonWord': ///
        \[
        |\]
        |\(
        |\)
        |\{
        |\}
        |[^\w_$`\[\]\(\)\{\}\s]+
    ///g

test_syntax =
    'String': /'.*?[^\\]'|".*?[^\\]"/
    'dot': /\./
    'assign': /\=/
    'bl': /\{/
    'br': /\}/
    'plus': /\+/
    'minus': /\-/
    'tilde': /\~/
    'func': /function/
    'pl': /\(/
    'pr': /\)/
    'comma': /\,/
    'nl': /\n+/
    'id': /[a-zA-Z_$][\w_$]*/
    'number': /\d+/

test_script = """
function foo(param1, param2){
    str = 'This is a string'
    another_str = "This is another string"
    bar = 1988
    return bar - bar + 25
}
foo.prototype
"""

lp = new Lexer.LexParser test_script, test_syntax
lp.tokenize()


#log lp.lex_list, 'Lexer', 4
stringEqual lp.lex_list, """
[["func","function"],["id","foo"],["pl","("],["id","param1"],["comma",","],["id","param2"],["pr",")"],["bl","{"],["nl","\\n"],["id","str"],["assign","="],["String","'This is a string'"],["nl","\\n"],["id","another_str"],["assign","="],["String","\\"This is another string\\""],["nl","\\n"],["id","bar"],["assign","="],["number","1988"],["nl","\\n"],["id","return"],["id","bar"],["minus","-"],["id","bar"],["plus","+"],["number","25"],["nl","\\n"],["br","}"],["nl","\\n"],["id","foo"],["dot","."],["id","prototype"]]
""", 'Lexer'


### MixMap ###

sampleA = [['a', '2'], ['b', '3'], ['c', '2'], ['a', '2'], ['b', '3'], ['c', '2'], ['a', '2'], ['b', '3'], ['c', '2'], ['b', 'bb'], ['c', 'a']]
sampleB = {S: {A: {}, B: {}, C: {D: {}}}}
sampleC = [{A: [1]}, {B: [2]}, {C: [3]}, {D: [4]}]
sampleD = {Q: [], W: {E: 1}, R: [2, 3]}

mm = new IR.MixMap
mm.arrange ['A', sampleA[3]], ['B', sampleB.S.A], ['C', sampleC[0]]
mm.arrange ['B', sampleB.S.C], ['A', sampleA[4]], ['C', sampleC[1].B]
mm.arrange ['A', sampleA[6]], ['B', sampleB.S.C.D], ['C', sampleC]
mm.arrange ['A', sampleA[6]], ['C', sampleC[2].C] # cover C
mm.arrange ['A', sampleA[6]], ['D', sampleD.R] # merge D

len = 0
for i of mm.ref_map
    len++

log len == 11, 'MixMap Length'

log sampleB.S.A == mm.get(sampleA[3], 'B'), 'MixMap 1'
log sampleB.S.C == mm.get(sampleA[4], 'B'), 'MixMap 2'
log sampleB.S.C.D == mm.get(sampleA[6], 'B'), 'MixMap 3'
log sampleA[3] == mm.get(sampleB.S.A, 'A'), 'MixMap 4'
log sampleA[4] == mm.get(sampleB.S.C, 'A'), 'MixMap 5'
log sampleA[6] == mm.get(sampleB.S.C.D, 'A'), 'MixMap 6'

log sampleC[2].C == mm.get(sampleB.S.C.D, 'C'), 'MixMap 7'

log sampleC[1].B == mm.get(sampleB.S.C, 'C'), 'MixMap 8'
log sampleC[1].B == mm.get(sampleA[4], 'C'), 'MixMap 9'
log sampleC[0] == mm.get(sampleA[3], 'C'), 'MixMap 10'
log sampleA[6] == mm.get(sampleC, 'A'), 'MixMap 11'
log sampleA[4] == mm.get(sampleC[1].B, 'A'), 'MixMap 12'
log sampleB.S.A == mm.get(sampleC[0], 'B'), 'MixMap 13'
log sampleB.S.C == mm.get(sampleC[1].B, 'B'), 'MixMap 14'
log sampleC[2].C == mm.get(sampleA[6], 'C'), 'MixMap 15'
log sampleA[6] == mm.get(sampleC[2].C, 'A'), 'MixMap 16'

log sampleB.S.C.D == mm.get(sampleD.R, 'B'), 'MixMap 17'
log sampleD.R == mm.get(sampleB.S.C.D, 'D'), 'MixMap 18'
log sampleC[2].C == mm.get(sampleD.R, 'C'), 'MixMap 19'
log sampleD.R == mm.get(sampleC[2].C, 'D'), 'MixMap 20'


### LR1 Parser ###

G = """
S -> E
E -> b A B x | A+ B | A d+ B
A -> a b
B -> b
B -> A | ( A + A )
A -> B * B
A -> c
"""
table = new LR1.SyntaxTable G, ['S'], [';']
state = new LR1.SyntaxParser [['a', 2], ['b', 3], ['c', 2], ['a', 2], ['b', 3], ['c', 2], ['a', 2], ['b', 3], ['c', 2], ['b', 'bb'], ';']
state.parseTable table

#log state.tree, 'SyntaxTree1', 4
stringEqual state.tree, """
{"parent":null,"leaves":[{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","leaves":[],"lex":"a","value":2},{"parent":"CR -> [object Object]","leaves":[],"lex":"b","value":3}],"lex":"A","value":null},{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","leaves":[],"lex":"c","value":2}],"lex":"A","value":null},{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","leaves":[],"lex":"a","value":2},{"parent":"CR -> [object Object]","leaves":[],"lex":"b","value":3}],"lex":"A","value":null},{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","leaves":[],"lex":"c","value":2}],"lex":"A","value":null},{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","leaves":[],"lex":"a","value":2},{"parent":"CR -> [object Object]","leaves":[],"lex":"b","value":3}],"lex":"A","value":null},{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","leaves":[],"lex":"c","value":2}],"lex":"A","value":null},{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","leaves":[],"lex":"b","value":"bb"}],"lex":"B","value":null}],"lex":"E","value":null}],"lex":"S","value":null}],"lex":"Syntax","value":null}
""", 'SyntaxTree 1'

ast = state.getAST ['a', 'B']

#log ast.syntax_tree, 'AST1', 4
stringEqual ast.syntax_tree, """
{"parent":null,"leaves":[{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","lex":"b","value":3}],"lex":"A"},{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","lex":"c","value":2}],"lex":"A"},{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","lex":"b","value":3}],"lex":"A"},{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","lex":"c","value":2}],"lex":"A"},{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","lex":"b","value":3}],"lex":"A"},{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","lex":"c","value":2}],"lex":"A"},{"parent":"CR -> [object Object]","lex":"b","value":"bb"}],"lex":"E"}],"lex":"S"}],"lex":"Syntax"}
""", 'AST 1'


table = new LR1.SyntaxTable G, ['S'], [';']
state = new LR1.SyntaxParser [['a', 2], ['b', 3], ['c', 2], ['a', 2], ['b', 3], 'a', ['b', 2], ['*', '*'], ['b', 4], ['a', 2], ['b', 3], ['c', 2], ['b', 'bb'], ';']
state.parseTable table

#log state.tree, 'SyntaxTree2', 4
stringEqual state.tree, """
{"parent":null,"leaves":[{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","leaves":[],"lex":"a","value":2},{"parent":"CR -> [object Object]","leaves":[],"lex":"b","value":3}],"lex":"A","value":null},{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","leaves":[],"lex":"c","value":2}],"lex":"A","value":null},{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","leaves":[],"lex":"a","value":2},{"parent":"CR -> [object Object]","leaves":[],"lex":"b","value":3}],"lex":"A","value":null},{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","leaves":[],"lex":"a","value":null},{"parent":"CR -> [object Object]","leaves":[],"lex":"b","value":2}],"lex":"A","value":null}],"lex":"B","value":null},{"parent":"CR -> [object Object]","leaves":[],"lex":"*","value":"*"},{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","leaves":[],"lex":"b","value":4}],"lex":"B","value":null}],"lex":"A","value":null},{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","leaves":[],"lex":"a","value":2},{"parent":"CR -> [object Object]","leaves":[],"lex":"b","value":3}],"lex":"A","value":null},{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","leaves":[],"lex":"c","value":2}],"lex":"A","value":null},{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","leaves":[],"lex":"b","value":"bb"}],"lex":"B","value":null}],"lex":"E","value":null}],"lex":"S","value":null}],"lex":"Syntax","value":null}
""", 'SyntaxTree 2'


ast = state.getAST ['a', 'B']

#log ast.syntax_tree, 'AST2', 4
stringEqual ast.syntax_tree, """
{"parent":null,"leaves":[{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","lex":"b","value":3}],"lex":"A"},{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","lex":"c","value":2}],"lex":"A"},{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","lex":"b","value":3}],"lex":"A"},{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","lex":"b","value":2}],"lex":"A"},{"parent":"CR -> [object Object]","lex":"*","value":"*"},{"parent":"CR -> [object Object]","lex":"b","value":4}],"lex":"A"},{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","lex":"b","value":3}],"lex":"A"},{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","lex":"c","value":2}],"lex":"A"},{"parent":"CR -> [object Object]","lex":"b","value":"bb"}],"lex":"E"}],"lex":"S"}],"lex":"Syntax"}
""", 'AST 2'



table = new LR1.SyntaxTable G, ['S'], [';']
state = new LR1.SyntaxParser [['a', 2], ['b', 3], ['d', 2], ['d', 2], ['c', 2], ['d', 2], ['b', 'bb'], ';']

state.parseTable table

#log state.tree, 'SyntaxTree3', 4
stringEqual state.tree, """
{"parent":null,"leaves":[{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","leaves":[],"lex":"a","value":2},{"parent":"CR -> [object Object]","leaves":[],"lex":"b","value":3}],"lex":"A","value":null},{"parent":"CR -> [object Object]","leaves":[],"lex":"d","value":2},{"parent":"CR -> [object Object]","leaves":[],"lex":"d","value":2},{"parent":"CR -> [object Object]","leaves":[],"lex":"c","value":2},{"parent":"CR -> [object Object]","leaves":[],"lex":"d","value":2},{"parent":"CR -> [object Object]","leaves":[],"lex":"b","value":"bb"}],"lex":"Syntax","value":null}
""", 'SyntaxTree 3 NO Parse'


ast = state.getAST ['a', 'B']

#log ast.syntax_tree, 'AST3', 4
stringEqual ast.syntax_tree, """
{"parent":null,"leaves":[{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","lex":"b","value":3}],"lex":"A"},{"parent":"CR -> [object Object]","lex":"d","value":2},{"parent":"CR -> [object Object]","lex":"d","value":2},{"parent":"CR -> [object Object]","lex":"c","value":2},{"parent":"CR -> [object Object]","lex":"d","value":2},{"parent":"CR -> [object Object]","lex":"b","value":"bb"}],"lex":"Syntax"}
""", 'AST 3'



G = """
S -> E
E -> [a e] c | (ax gx)* cx cx | A d+ B
A -> a b
A -> c
B -> b
"""

table = new LR1.SyntaxTable G, ['S'], [';']
state = new LR1.SyntaxParser ['ax', 'gx','ax', 'gx','ax', 'gx', 'cx', 'cx', ';']

state.parseTable table

#log state.tree, 'SyntaxTree4', 4
stringEqual state.tree, """
{"parent":null,"leaves":[{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","leaves":[],"lex":"ax","value":null},{"parent":"CR -> [object Object]","leaves":[],"lex":"gx","value":null}],"lex":"E!hswru3v7","value":null},{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","leaves":[],"lex":"ax","value":null},{"parent":"CR -> [object Object]","leaves":[],"lex":"gx","value":null}],"lex":"E!hswru3v7","value":null},{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","leaves":[],"lex":"ax","value":null},{"parent":"CR -> [object Object]","leaves":[],"lex":"gx","value":null}],"lex":"E!hswru3v7","value":null},{"parent":"CR -> [object Object]","leaves":[],"lex":"cx","value":null},{"parent":"CR -> [object Object]","leaves":[],"lex":"cx","value":null}],"lex":"E","value":null}],"lex":"S","value":null}],"lex":"Syntax","value":null}
""", 'SyntaxTree 4'


ast = state.getAST ['a', 'B']

#log ast.syntax_tree, 'AST4', 4
stringEqual ast.syntax_tree, """
{"parent":null,"leaves":[{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","lex":"ax"},{"parent":"CR -> [object Object]","lex":"gx"},{"parent":"CR -> [object Object]","lex":"ax"},{"parent":"CR -> [object Object]","lex":"gx"},{"parent":"CR -> [object Object]","lex":"ax"},{"parent":"CR -> [object Object]","lex":"gx"},{"parent":"CR -> [object Object]","lex":"cx"},{"parent":"CR -> [object Object]","lex":"cx"}],"lex":"E"}],"lex":"S"}],"lex":"Syntax"}
""", 'AST 4'


table = new LR1.SyntaxTable G, ['S'], [';']
state = new LR1.SyntaxParser ['cx', 'cx', ';']

state.parseTable table

#log state.tree, 'SyntaxTree5', 4
stringEqual state.tree, """
{"parent":null,"leaves":[{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","leaves":[],"lex":"cx","value":null},{"parent":"CR -> [object Object]","leaves":[],"lex":"cx","value":null}],"lex":"E","value":null}],"lex":"S","value":null}],"lex":"Syntax","value":null}
""", 'SyntaxTree 5'


ast = state.getAST ['cx']

#log ast.syntax_tree, 'AST5', 4
stringEqual ast.syntax_tree, """
{"parent":null,"leaves":[{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","lex":"E"}],"lex":"S"}],"lex":"Syntax"}
""", 'AST 5'



G = """
S -> S1+
S1 -> S2
S2 -> S3
S3 -> a b
"""
table = new LR1.SyntaxTable G, ['S'], [';']
state = new LR1.SyntaxParser ['a', 'b', 'a', 'b', ';']

state.parseTable table

#log state.tree, 'SyntaxTree6', 4
stringEqual state.tree, """
{"parent":null,"leaves":[{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","leaves":[],"lex":"a","value":null},{"parent":"CR -> [object Object]","leaves":[],"lex":"b","value":null}],"lex":"S3","value":null}],"lex":"S2","value":null}],"lex":"S1","value":null},{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","leaves":[],"lex":"a","value":null},{"parent":"CR -> [object Object]","leaves":[],"lex":"b","value":null}],"lex":"S3","value":null}],"lex":"S2","value":null}],"lex":"S1","value":null}],"lex":"S","value":null}],"lex":"Syntax","value":null}
""", 'SyntaxTree 6'


ast = state.getAST ['S2', 'S3']

#log ast.syntax_tree, 'AST6', 4
stringEqual ast.syntax_tree, """
{"parent":null,"leaves":[{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","lex":"a"},{"parent":"CR -> [object Object]","lex":"b"}],"lex":"S1"},{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","lex":"a"},{"parent":"CR -> [object Object]","lex":"b"}],"lex":"S1"}],"lex":"S"}],"lex":"Syntax"}
""", 'AST 6'



G = """
S -> E+
E -> a b End | c a b End | c A End
A -> e t
"""
table = new LR1.SyntaxTable G, ['S'], [';']
state = new LR1.SyntaxParser [['a', 1], ['b', 2], 'End', ['a', 3], ['b', 4], ['a', 5], 'End' , ['c', 6], ['a', 7
], ['b', 8], 'End', ['c', 9], ['e', 10], ['t', 11], 'End', ';']
state.sync_lex = ['End', 'Fail', 'E']
state.parseTable table

#log state.tree, 'SyntaxTree Except Recover 1', 4
stringEqual state.tree, """
{"parent":null,"leaves":[{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","leaves":[],"lex":"a","value":1},{"parent":"CR -> [object Object]","leaves":[],"lex":"b","value":2},{"parent":"CR -> [object Object]","leaves":[],"lex":"End","value":null}],"lex":"E","value":null},{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","leaves":[],"lex":"a","value":3},{"parent":"CR -> [object Object]","leaves":[],"lex":"b","value":4},{"parent":"CR -> [object Object]","leaves":[],"lex":"a","value":5},{"parent":"CR -> [object Object]","leaves":[],"lex":"End","value":null}],"lex":"Fail","value":null}],"lex":"E","value":null},{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","leaves":[],"lex":"c","value":6},{"parent":"CR -> [object Object]","leaves":[],"lex":"a","value":7},{"parent":"CR -> [object Object]","leaves":[],"lex":"b","value":8},{"parent":"CR -> [object Object]","leaves":[],"lex":"End","value":null}],"lex":"E","value":null},{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","leaves":[],"lex":"c","value":9},{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","leaves":[],"lex":"e","value":10},{"parent":"CR -> [object Object]","leaves":[],"lex":"t","value":11}],"lex":"A","value":null},{"parent":"CR -> [object Object]","leaves":[],"lex":"End","value":null}],"lex":"E","value":null}],"lex":"S","value":null}],"lex":"Syntax","value":null}
""", 'SyntaxTree Except Recover 1'



G = """
Program -> S1+
S1 -> S2
S2 -> S3
S3 -> a* b c d
"""
table = new LR1.SyntaxTable G, ['Program'], [';']
state = new LR1.SyntaxParser ['S1', 'a', 'b', 'c', 'd', ';']

state.parseTable table
#log state.tree, 'SyntaxTree 7', 4
stringEqual state.tree, """
{"parent":null,"leaves":[{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","leaves":[],"lex":"S1","value":null},{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","leaves":[{"parent":"CR -> [object Object]","leaves":[],"lex":"a","value":null},{"parent":"CR -> [object Object]","leaves":[],"lex":"b","value":null},{"parent":"CR -> [object Object]","leaves":[],"lex":"c","value":null},{"parent":"CR -> [object Object]","leaves":[],"lex":"d","value":null}],"lex":"S3","value":null}],"lex":"S2","value":null}],"lex":"S1","value":null}],"lex":"Program","value":null}],"lex":"Syntax","value":null}
""", 'SyntaxTree 7'


G = """
S -> E
E -> b A B x | A+ B | A d+ B
A -> a b
B -> b
B -> A | ( A + A )
A -> B * B
A -> c
"""

sampleLex = [['a', '2'], ['b', '3'], ['c', '2'], ['a', '2'], ['b', '3'], ['c', '2'], ['a', '2'], ['b', '3'], ['c', '2'], ['b', 'bb'], ';']
table = new LR1.SyntaxTable G, ['S'], [';']

mm = new IR.MixMap
LR1.SyntaxParser.Mix.mixer = ->
    mm.arrange.apply mm, arguments

state = new LR1.SyntaxParser sampleLex
state.parseTable table

ast = state.getAST []
log ast.syntax_tree.leaves[0].leaves[0].leaves[0].leaves[0] == mm.get(sampleLex[0], 'SyntaxNode'), 'AST Lex MixMap 1'
log ast.syntax_tree.leaves[0].leaves[0].leaves[0].leaves[1] == mm.get(sampleLex[1], 'SyntaxNode'), 'AST Lex MixMap 2'
log ast.syntax_tree.leaves[0].leaves[0].leaves[1].leaves[0] == mm.get(sampleLex[2], 'SyntaxNode'), 'AST Lex MixMap 3'
log ast.syntax_tree.leaves[0].leaves[0].leaves[2].leaves[0] == mm.get(sampleLex[3], 'SyntaxNode'), 'AST Lex MixMap 4'
log ast.syntax_tree.leaves[0].leaves[0].leaves[2].leaves[1] == mm.get(sampleLex[4], 'SyntaxNode'), 'AST Lex MixMap 5'
log ast.syntax_tree.leaves[0].leaves[0].leaves[3].leaves[0] == mm.get(sampleLex[5], 'SyntaxNode'), 'AST Lex MixMap 6'
log ast.syntax_tree.leaves[0].leaves[0].leaves[4].leaves[0] == mm.get(sampleLex[6], 'SyntaxNode'), 'AST Lex MixMap 7'
log ast.syntax_tree.leaves[0].leaves[0].leaves[4].leaves[1] == mm.get(sampleLex[7], 'SyntaxNode'), 'AST Lex MixMap 8'
log ast.syntax_tree.leaves[0].leaves[0].leaves[5].leaves[0] == mm.get(sampleLex[8], 'SyntaxNode'), 'AST Lex MixMap 9'
log ast.syntax_tree.leaves[0].leaves[0].leaves[6].leaves[0] == mm.get(sampleLex[9], 'SyntaxNode'), 'AST Lex MixMap 10'
log sampleLex[9] == mm.get(ast.syntax_tree.leaves[0].leaves[0].leaves[6].leaves[0], 'Lex'), 'AST Lex MixMap 11'


### Zipper ###

G = """
S -> E
E -> b A B x | A+ B | A d+ B
A -> a b
B -> b
B -> A | ( A + A )
A -> B * B
A -> c
"""
table = new LR1.SyntaxTable G, ['S'], [';']
state = new LR1.SyntaxParser [['a', '2'], ['b', '3'], ['c', '2'], ['a', '2'], ['b', '3'], ['c', '2'], ['a', '2'], ['b', '3'], ['c', '2'], ['b', 'bb'], ';']
state.parseTable table

ast = state.getAST []

selectedB = Zipper.Zipper.select ast.syntax_tree, 'B'
stringEqual selectedB.length.toString(), '1', 'Zipper Select Length 1'
log selectedB[0].parent.parent.parent == ast.syntax_tree, 'Zipper Select 1'


selectedBb = Zipper.Zipper.select ast.syntax_tree, 'B b'
stringEqual selectedBb.length.toString(), '1', 'Zipper Select Length 2'
log selectedBb[0].parent == selectedB[0], 'Zipper Select 2'

selectedA = Zipper.Zipper.select ast.syntax_tree, 'A'
stringEqual selectedA.length.toString(), '6', 'Zipper Select Length 3'
log selectedA[0].parent.parent.parent == ast.syntax_tree, 'Zipper Select 3'


selectedAb = Zipper.Zipper.select ast.syntax_tree, 'A b'
stringEqual selectedAb.length.toString(), '3', 'Zipper Select Length 4'
log selectedAb[0].parent == selectedA[0], 'Zipper Select 4'


selectedValBb = Zipper.Zipper.select ast.syntax_tree, '~3'
stringEqual selectedValBb.length.toString(), '3', 'Zipper Value Select Length 1'
log selectedValBb[0].parent == selectedA[0], 'Zipper Value Select 1 - 1'
log selectedValBb[2].parent == selectedA[4], 'Zipper Value Select 1 - 2'

selectedValbb = Zipper.Zipper.select ast.syntax_tree, '~bb'
stringEqual selectedValbb.length.toString(), '1', 'Zipper Value Select Length 2'
log selectedValbb[0].parent == selectedB[0], 'Zipper Value Select 2'

selectedValBbb = Zipper.Zipper.select ast.syntax_tree, 'B ~bb'
stringEqual selectedValBbb.length.toString(), '1', 'Zipper Value Select Length 3'
log selectedValBbb[0] == selectedValbb[0], 'Zipper Value Select 3'




### SymbolTable ###
sampleAST = {
    lex: 'S',
    leaves: [
        {
            lex: 'A',
            leaves: [
                {lex: 'Receiver', value: 1},
                {lex: 'Giver', value: 1}
            ]
        },
        {
            lex: 'FN',
            leaves: [
                {
                    lex: 'A',
                    leaves: [
                        {lex: 'Receiver', value: 2},
                        {lex: 'Giver', value: 2}
                    ]
                },
                {
                    lex: 'A',
                    leaves: [
                        {lex: 'Receiver', value: 3},
                        {lex: 'Giver', value: 3}
                    ]
                },
                {
                    lex: 'FN',
                    leaves: [
                        {
                            lex: 'A',
                            leaves: [
                                {lex: 'Receiver', value: 4},
                                {lex: 'Giver', value: 4}
                            ]
                        },
                        {
                            lex: 'A',
                            leaves: [
                                {lex: 'Receiver', value: 5},
                                {lex: 'Giver', value: 5}
                            ]
                        }
                    ]
                }
            ]
        },
        {
            lex: 'A',
            leaves: [
                {lex: 'Receiver', value: 6},
                {
                    lex: 'Giver',
                    leaves: [
                        {
                            lex: 'A',
                            leaves: [
                                {lex: 'Receiver', value: 7},
                                {lex: 'Giver', value: 7},

                            ]
                        }
                    ]
                }
            ]
        },
        {
            lex: 'A',
            leaves: [
                {lex: 'Receiver', value: 6},
                {
                    lex: 'Giver',
                    leaves: [
                        {
                            lex: 'A',
                            leaves: [
                                {lex: 'Receiver', value: 8},
                                {lex: 'Giver', value: 8},

                            ]
                        }
                    ]
                }
            ]
        },
        {
            lex: 'FN',
            leaves: [
                {
                    lex: 'A',
                    leaves: [
                        {lex: 'Receiver', value: 9},
                        {lex: 'Giver', value: 9}
                    ]
                }
            ]
        }
    ]
}

mm = new IR.MixMap
SymbolTable.SymbolTable.Mix.mixer = ->
    mm.arrange.apply mm, arguments

tables = SymbolTable.SymbolTable.walkGenerate sampleAST, {Receiver: ((x) -> x), Giver: null}, ['FN']
log 4 == tables.length, 'SymbolTable Return Length 1'

log 5 == mm.get(sampleAST, 'SymbolTable').stack.length, 'SymbolTable Stack Length 1'
log sampleAST.leaves[0].leaves[0] == mm.get(sampleAST, 'SymbolTable').stack[0].Receiver, 'SymbolTable 1'
log sampleAST.leaves[0].leaves[1] == mm.get(sampleAST, 'SymbolTable').stack[0].Giver, 'SymbolTable 2'
log sampleAST.leaves[2].leaves[0] == mm.get(sampleAST, 'SymbolTable').stack[1].Receiver, 'SymbolTable 3'
log sampleAST.leaves[2].leaves[1] == mm.get(sampleAST, 'SymbolTable').stack[1].Giver, 'SymbolTable 4'

log 2 == mm.get(sampleAST.leaves[1], 'SymbolTable').stack.length, 'SymbolTable Stack Length 2'
log mm.get(sampleAST, 'SymbolTable') == mm.get(sampleAST.leaves[1], 'SymbolTable').parent, 'SymbolTable Parent 1'
log sampleAST.leaves[1].leaves[0].leaves[0] == mm.get(sampleAST.leaves[1], 'SymbolTable').stack[0].Receiver, 'SymbolTable 5'
log sampleAST.leaves[1].leaves[0].leaves[1] == mm.get(sampleAST.leaves[1], 'SymbolTable').stack[0].Giver, 'SymbolTable 6'
log sampleAST.leaves[1].leaves[1].leaves[0] == mm.get(sampleAST.leaves[1], 'SymbolTable').stack[1].Receiver, 'SymbolTable 7'
log sampleAST.leaves[1].leaves[1].leaves[1] == mm.get(sampleAST.leaves[1], 'SymbolTable').stack[1].Giver, 'SymbolTable 8'


log 2 == mm.get(sampleAST.leaves[1].leaves[2], 'SymbolTable').stack.length, 'SymbolTable Stack Length 3'
log mm.get(sampleAST.leaves[1], 'SymbolTable') == mm.get(sampleAST.leaves[1].leaves[2], 'SymbolTable').parent, 'SymbolTable Parent 2'
log sampleAST.leaves[1].leaves[2].leaves[0].leaves[0] == mm.get(sampleAST.leaves[1].leaves[2], 'SymbolTable').stack[0].Receiver, 'SymbolTable 9'
log sampleAST.leaves[1].leaves[2].leaves[0].leaves[1] == mm.get(sampleAST.leaves[1].leaves[2], 'SymbolTable').stack[0].Giver, 'SymbolTable 10'
log sampleAST.leaves[1].leaves[2].leaves[1].leaves[0] == mm.get(sampleAST.leaves[1].leaves[2], 'SymbolTable').stack[1].Receiver, 'SymbolTable 11'
log sampleAST.leaves[1].leaves[2].leaves[1].leaves[1] == mm.get(sampleAST.leaves[1].leaves[2], 'SymbolTable').stack[1].Giver, 'SymbolTable 12'


log 1 == mm.get(sampleAST.leaves[4], 'SymbolTable').stack.length, 'SymbolTable Stack Length 4'
log mm.get(sampleAST, 'SymbolTable') == mm.get(sampleAST.leaves[4], 'SymbolTable').parent, 'SymbolTable Parent 3'
log sampleAST.leaves[4].leaves[0].leaves[0] == mm.get(sampleAST.leaves[4], 'SymbolTable').stack[0].Receiver, 'SymbolTable 13'
log sampleAST.leaves[4].leaves[0].leaves[1] == mm.get(sampleAST.leaves[4], 'SymbolTable').stack[0].Giver, 'SymbolTable 14'


mm = new IR.MixMap
SymbolTable.SymbolTable.Mix.mixer = ->
    mm.arrange.apply mm, arguments

tables = SymbolTable.SymbolTable.walkGenerate sampleAST, {Receiver: ((x) -> x.value), Giver: null}, ['FN']
log 4 == tables.length, 'SymbolTable Return Length 2'

log 1 == mm.get(sampleAST, 'SymbolTable').stack[0].Receiver, 'SymbolTable 15'
log 6 == mm.get(sampleAST, 'SymbolTable').stack[1].Receiver, 'SymbolTable 16'

log 4 == mm.get(sampleAST.leaves[1].leaves[2], 'SymbolTable').stack[0].Receiver, 'SymbolTable 17'
log 5 == mm.get(sampleAST.leaves[1].leaves[2], 'SymbolTable').stack[1].Receiver, 'SymbolTable 18'


log 5 == mm.get(sampleAST, 'SymbolTable').stack.length, 'SymbolTable Stack Length 5'
log sampleAST.leaves[3].leaves[1] == mm.get(sampleAST, 'SymbolTable').lookUpTop({Receiver: 6}).Giver, 'SymbolTable LookUp 1'
log sampleAST.leaves[3].leaves[1] == mm.get(sampleAST, 'SymbolTable').lookUpTop({Receiver: sampleAST.leaves[3].leaves[0]}).Giver, 'SymbolTable LookUp 2'
log sampleAST.leaves[1].leaves[2].leaves[1].leaves[1] == mm.get(sampleAST.leaves[1].leaves[2], 'SymbolTable').lookUpTop({Receiver: 5}).Giver, 'SymbolTable LookUp 3'
log sampleAST.leaves[1].leaves[0].leaves[1] == mm.get(sampleAST.leaves[1].leaves[2], 'SymbolTable').lookUpTop({Receiver: 2}).Giver, 'SymbolTable LookUp 4'
log sampleAST.leaves[0].leaves[1] == mm.get(sampleAST.leaves[1].leaves[2], 'SymbolTable').lookUpTop({Receiver: 1}).Giver, 'SymbolTable LookUp 5'
log sampleAST.leaves[3].leaves[1].leaves[0].leaves[1] == mm.get(sampleAST.leaves[1].leaves[2], 'SymbolTable').lookUpTop({Receiver: 8}).Giver, 'SymbolTable LookUp 6'
log sampleAST.leaves[3].leaves[1] == mm.get(sampleAST.leaves[1].leaves[2], 'SymbolTable').lookUpTop({Receiver: 6}).Giver, 'SymbolTable LookUp 7'