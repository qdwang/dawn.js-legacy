## Syntax Parser

Syntax Parser is a parser to generate syntax tree from lex list

## How it works

```
[
    ['A', 'a'],
    ['B', 'b'],
    ['C', 'c'],
    ['D', 'd'],
    'End'
]

    ----> LR1 Parser with grammar syntax definition ---->

```
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
grammar = '
    Stmt -> ABC D \n\
    ABC -> A BC \n\
    BC -> B C \n\
    '

syntax_table = new SyntaxTable(grammer, ['Stmt'], ['End'])
syntax_parser = new SyntaxParser(lex_list)
syntax_parser.parseTable(syntax_table)
syntax_parser.tree // we will get the syntax tree
syntax_parser.getAST(['ABC']) // we will get the AST without the node of the lex is 'ABC'
```

## Definition

### SyntaxParser
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

sync_lex -> define the recover way of parsing fail

tree -> parsed syntax tree result
```

// TO BE CONTINUED...