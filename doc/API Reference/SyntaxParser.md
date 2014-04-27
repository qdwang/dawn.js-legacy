## Syntax Parser

Syntax Parser is a parser to generate syntax tree from lex list

### How it works

```
[
    ['A', 'a'],
    ['B', 'b'],
    ['C', 'c'],
    ['D', 'd'],
    'End'
]

    ----> LR1 Parser with grammar syntax definition ---->

{
    lex: 'Stmt',
    leaves: [
        {
            lex: 'ABC',
            leaves: [
                {
                    lex: 'A',
                    value: 'a'
                },
                {
                    lex: 'BC',
                    leaves: [
                        {lex: 'B', 'b'},
                        {lex: 'C', 'c'}
                    ]
                }
            ]
        },
        {
            lex: 'D',
            value: 'd'
        }
    ]
}
```

**Sample**
```
lex_list = [
        ['A', 'a'],
        ['B', 'b'],
        ['C', 'c'],
        ['D', 'd'],
        'End'
    ]

// if coffee is used, this definition will be prettier
grammar = ' \
    Stmt -> ABC D \n\
    ABC -> A BC \n\
    BC -> B C \n\
    '

syntax_table = new SyntaxTable(grammar, ['Stmt'], ['End'])
syntax_parser = new SyntaxParser(lex_list)
syntax_parser.parseTable(syntax_table)
syntax_parser.tree // we will get the syntax tree
syntax_parser.getAST(['ABC']) // we will get the AST without the node of the lex is 'ABC'
```

### Definition

#### new SyntaxParser
get instance of SyntaxParser
```
syntax_parser = new SyntaxParser(
    input lex -> array
)
```

**Instance Attributes**
```
raw_input_lex -> input lex contains value
input_lex -> input lex without value
input_vale -> input value without lex

stack -> remained lex to be parsed

sync_lex -> define how to recover if parsing fail

tree -> parsed syntax tree result
```

#### SyntaxParser.flow (static method)
The flow of SyntaxParser

flow args must contain:
```
input_args = {
    grammar: grammar definition,
    start_stmt: from which statement to start parsing,
    end_lex: detect which lex to end parsing,
    sync_lex: define how to recover if parsing fail,
    lex_list: lex result from LexParser,
    mix_map: mix map object,
    ast_cutter: types of nodes need to be cut
}
```
this flow will output:
```
args_will_be_combined = {
    ast: parsed result AST
}
```


#### syntax_parser.getAST
get AST from syntax_parser.tree
```
syntax_parser.getAST(
    cut patterns -> array
)
```

#### syntax_parser.shift
LR1 shift
```
syntax_parser.shift()
```

#### SyntaxParser.checkIfReduce (static method)
LR1 reduce detect handler
```
SyntaxParser.checkIfReduce(
    syntax table, -> SyntaxTable
    stack need to be detect, -> array
    look ahead, -> string
)
```

#### syntax_parser.reduce
make reduce
```
syntax_parser.reduce(
    syntax table, -> SyntaxTable
    if should assign value to reduction -> bool
)
```

#### syntax_parser.generateTree
generate syntax tree from reduction
```
syntax_parser.generateTree(
    if should assign value to reduction -> bool
)
```
#### syntax_parser.parseTable
walk the whole shifting and reducing procedure
```
syntax_parser.parseTable(
    syntax table -> SyntaxTable
)
```

#### SyntaxParser.Mix (static method)
this mix function will be invoked during syntax_parser.generateTree
if `SyntaxParser.Mix.mixer` is defined as a function, it will work
```
SyntaxParser.Mix.mixer = function(){
    handler(
        ['SyntaxNode', syntax_node],
        ['Lex', lex]
    )
}
```

#### SyntaxParser.rebuild (static method)
rebuild the parent reference of nodes of syntax tree parsed from plain text of syntax tree, and help to reconstruct mix map
```
SyntaxParser.rebuild(
    non-parent syntax tree, -> object
    mix map for recover -> MixMap
)
```