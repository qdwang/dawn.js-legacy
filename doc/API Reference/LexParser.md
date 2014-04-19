## LexParser

LexParser is a parser to tokenize the code script

## How it works

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
```js
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

## Definition

### LexParser
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

### LexParser.flow
The flow of LexParser

flow args must contain:
```
input_args = {
    script: script,
    lex_syntax: lex_syntax,
    cursor_pos: cursor_pos
}
```

This flow will output:
```
args_will_be_combined = {
    lex_list: lex_list,
    cursor_lex: cursor_lex,
    end_lex: end_lex // The lex define the End of Program
}
```

### lex_parser.tokenize
tokenize the script
```
lex_parser.tokenize(
    cursor position -> number
)
```
