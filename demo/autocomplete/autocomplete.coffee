importScripts './../../src/ulti.js'
importScripts './../../src/BNF-parser.js'
importScripts './../../src/IR.js'
importScripts './../../src/Zipper.js'
importScripts './../../src/flow.js'
importScripts './../../src/lex-parser.js'
importScripts './../../src/LR1-parser.js'
importScripts './../../src/symbol-table.js'


lex_syntax =
    'String': /'.*?[^\\]'|".*?[^\\]"/
    'Dot': /\./
    'Func': /function/
    'StmtEnd': /;|\n/
    'Assign': /\=/
    'Pl': /\(/
    'Pr': /\)/
    'Bl': /\{/
    'Br': /\}/
    'Comma': /\,/
    'Var': /var/
    'Id': /[a-zA-Z_$][\w_$]*/


grammer = """
Program -> S+
S -> SGO StmtEnd | StmtEnd
SGO -> Obj | StmtEnd | Assignment
Assignment -> Var* Receiver Assign Giver
Receiver -> Obj
Giver -> Obj | Function
Function -> Func Id* Pl Args* Pr Bl S* Br
Obj -> Id (Dot Id)* | Bl Br
Args -> Id (Comma Id)*
"""

markers = {
    Receiver: (
        (x) -> getObjectName x
    ),
    Giver: (
        (x) -> x
    )}


getObjectName = (obj_node, top=false) ->
    ids = self.Zipper.select obj_node, 'Id'
    name = ''
    for id in ids
        name += id.value + '.'
        if top
            break

    name.slice(0, -1)


parseFlow = (script, cursor_pos) ->
        args =
            script: script
            lex_syntax: lex_syntax
            cursor_pos: cursor_pos

            grammer: grammer
            start_stmt: ['Program']
            sync_lex: ['StmtEnd', 'ParseFail', 'S']
            mix_map: new self.MixMap
            ast_cutter: []

            markers: markers
            scope_rules: ['Function']


        flow = new self.Flow args
        flow.append([
            self.LexParser.flow
            self.SyntaxParser.flow
            self.SymbolTable.flow
        ])
        flow.finish()

        cursor_lex = flow.result 'cursor_lex'
        mm = flow.result 'mix_map'
        ast = flow.result 'ast'

        # not parsing flow
        if not cursor_lex
            self.postMessage 'no lex found'
            return null

        curr_ast_node = mm.get cursor_lex, 'SyntaxNode'

        curr_obj_node = self.Zipper.findParent {lex: 'Obj'}, curr_ast_node
        scope_node = self.Zipper.findParent {lex: 'Function'}, curr_ast_node
        if not scope_node
            scope_node = ast

        curr_symbol_table = mm.get scope_node, 'SymbolTable'


        if curr_obj_node
            curr_obj_name = getObjectName curr_obj_node, true

            result = curr_symbol_table.filter((
                (record)->
                    if record.Receiver.indexOf(curr_obj_name) > -1 then true else false
            ), 1)

            for i in result
                self.postMessage i.Receiver
        else
            self.postMessage 'no reference found'

self.onmessage = (e) ->
    data = JSON.parse e.data
    parseFlow(data['script'], data['cursor_pos']);
