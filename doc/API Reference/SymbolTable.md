## Symbol Table

SymbolTable is a grid system to store specific data for syntax tree

## How it works
```
marker -> {'A': function(){}, 'B': function(){}}

inside:
    A       B
    a1      b1
    a2      b2
    a3      b3
    ...     ...

parent -> other symbol table instance
```

**Sample**
```
ast = {
    lex: 'A',
    leaves: [
        {
            lex: 'Scope'
            leaves: [
                {
                    lex: 'KeyA',
                    value: 1
                },
                {
                    lex: 'KeyB',
                    value: 2
                }
            ]
        }
    ]

}

marker = {
    'KeyA': function(x){return x.value},
    'KeyB': function(x){return x}
}

scope = ['Scope']
symbol_tables = SymbolTable.walkGenerate(ast, marker, scope)
```

## Definition

### SymbolTable
get instance of SymbolTable
```
symbol_table = new SymbolTable(
    grid column markers -> object
    )
```

**Instance Attributes**
```
markers -> input markers
stack -> place to store parsed data
parent -> parent symbol table
```

### SymbolTable.flow (static method)
The flow of SymbolTable

flow args must contain:
```
input_args = {
    ast: AST,
    markers: define the symbol table column,
    scope_rules: define what kind of node is scope node,
    mix_map: mix map
}
```
this flow will output:
```
args_will_be_combined = {
    symbol_tables: generated symbol tables
}
```

### SymbolTable.walkGenerate (static method)
generate symbol table from syntax tree
```
SymbolTable.walkGenerate(
    syntax tree like ast, -> object
    markers, -> object
    scope rules -> array
)
```

### symbol_table.convert
convert obj via definition of symbol_table.markers
```
symbol_table.convert(
    object -> object
)
```

### SymbolTable.match (static method)
if objectA contains keys and values of objectB
```
SymbolTable.match(
    objectA, -> object
    objectB -> object
)
```

### symbol_table.push
push row to symbol_table.stack
```
symbol_table.push(
    object record -> object
)
```

### symbol_table.concat
concatenate rows to symbol_table.stack
```
symbol_table.concat(
    object record 1, -> object
    object record 2, -> object
    ... -> object
)
```

### symbol_table.lookUpTop
look up for the specific record from stack top
if nothing is found it will search the search the parent symbol table
```
symbol_table.lookUpTop(
    condition object -> object
)
```

### symbol_table.filter
get specific records
```
symbol_table.filter(
    filter method, -> function
    scope_mode
        0 -> only lookup current scope
        1 -> will lookup parent scope if no matches in current scope
        2 -> matches in all scopes
)
```
### SyntaxTable.Mix
this mix function will be invoked during SyntaxTable.walkGenerate
if `SyntaxTable.Mix.mixer` is defined as a function, it will work

```
SyntaxTable.Mix.mixer = function(){
    handler(
        ['SyntaxNode', syntax_scope_node],
        ['SymbolTable', symbol_table]
    )
}
