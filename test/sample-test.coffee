js_lang = require './../javascript-lang.js'
Lex = require './../src/lex-parser.js'
LR1 = require './../src/LR1-parser.js'
IR = require './../src/IR.js'
ST = require './../src/symbol-table.js'
ulti = require './../src/ulti.js'

non_word = """./\()"':,.;<>~!@#$%^&*|+=[]{}`~?-"""

log = ulti.log

script = """
abc.e(fe,gge)

abc.e()

fff.gg();

var gt = efne;

function abc(){
    var cc = eeg;
    cc.eegh();
}
"""

lp = new Lex.LexParser script, js_lang.prepare_syntax, js_lang.lex_syntax

lp.getPatterns()

lp.lex_list.push 'ProgramEnd'

mm = new IR.MixMap
LR1.SyntaxParser.Mix.mixer = ->
    mm.arrange.apply mm, arguments

ST.SymbolTable.Mix.mixer = ->
    mm.arrange.apply mm, arguments

table = new LR1.SyntaxTable js_lang.grammer, ['Program'], ['ProgramEnd']
state = new LR1.SyntaxParser lp.lex_list


state.parseTable table

ast = state.getAST [
                    'Link',
                    'stmtend',
                    'NewLine',
                    'Comma',
                    'ParenStart',
                    'ParenEnd',
                    'SGO',
                    'StmtEnd',
                    'BlockStart',
                    'BlockEnd',
                    'VariableDecl',
                    'S',
                    'Assign'
                    ]

#log mm.get(lp.lex_list[35])

markers = {Receiver: ((x) -> x), Giver: ((x) -> x)}

st = ST.SymbolTable.walkGenerate ast.syntax_tree, markers, ['Function']

log ast.syntax_tree
receiver_scope = mm.get(lp.lex_list[35], 'SyntaxNode').parent.parent.parent.parent

result = mm.get(receiver_scope, 'SymbolTable').lookUpTop {Receiver: mm.get(lp.lex_list[35], 'SyntaxNode').parent.parent}

log result.Receiver
log result.Giver
