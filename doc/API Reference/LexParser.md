## LexParser

LexParser is a parser to tokenize the code script

### How it works

```
'var foo = function(){};'

    ----> LexParser with lex syntax definition ---->

[
    ['VarDecl', 'var'],
    ['Identifier', 'foo'],
    ['AssignSymbol', '='],
    ['FunctionDecl', 'function'],
    ['ParenLeft', '('],
    ['ParenRight', ')'],
    ['BracketLeft', '{'],
    ['BracketRight', '}'],
    ['End', ';']
]
```

**Sample**
```
script = 'var foo = function(){};'
lex_syntax = { // The key order will affect the result
    'VarDecl': /var/,
    'AssignSymbol': /=/,
    'FunctionDecl': /function/,
    'ParenLeft': /\(/,
    'ParenRight': /\)/,
    'BracketLeft': /\{/,
    'BracketRight': /\}/,
    'End': /;\n/,
    'Identifier': /[a-zA-Z_$][\w_$]*/
}

lex_parser = LexParser(script, lex_syntax)
lex_parser.tokenize(5) // 5 means current cursor position, it's for getting the current point lex

lex_parser.lex_list // we get the lex result list
lex_parser.cursor_lex // we get the current point lex
```

### Definition

#### new LexParser
get instance of LexParser
```
lex_parser = new LexParser(
    input script, -> string
    lex syntax -> object // The key order should be deterministic, it will affect the result of parsing.
    )
```

**Instance Attributes**
```
script -> input script
lex_syntax -> input lex syntax

lex_list -> parsed lex result
cursor_lex -> current point lex
```

#### LexParser.flow  (static method)
The flow of LexParser

flow args must contain:
```
input_args = {
    script: origin script content,
    lex_syntax: definition of lex syntax,
    cursor_pos: current cursor position
}
```

this flow will output:
```
args_will_be_combined = {
    lex_list: lex result after parsing,
    cursor_lex: current cursor lex,
    end_lex: the lex define the End of Program
}
```

#### lex_parser.tokenize
tokenize the script
```
lex_parser.tokenize(
    cursor position -> number
)
```

#### lex_parser.make_dedent
generate dedent for language like Python
```
lex_parser.make_dedent(
    base_lex: lex to be the indent, -> string
    insert_lex: lex to be the dedent -> string
)
```

#### LexParser.rebuild (static method)
help to reconstruct mix map
```
SyntaxParser.rebuild(
    lex list, -> array
    mix map for recover -> MixMap
)
```