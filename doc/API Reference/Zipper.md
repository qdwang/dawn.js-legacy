## Zipper

Zipper is a set of utilities to deal with tree structure

## Definition

### Zipper
get instance of Zipper
```
zipper = new Zipper(
    tree -> object
    )
```

**Instance Attributes**
```
tree -> input tree
curr_node -> current node
```
### zipper.up
turn current node to be its parent node
```
zipper.up()
```

### zipper.down
turn current node to be its child node in recursively
```
zipper.down(
    css selector -> string
)
```

### zipper.parent
turn current node to be its specific parent node in recursively
```
zipper.parent(
    the feature of parent node wanted -> object
)
```
### zipper.node
get current node
```
zipper.node()
```


### Zipper.select (static method)
get nodes from css selector style syntax
the default css selector syntax is Zipper.selectorAST
```
Zipper.select(
   root node, -> object
   css selector -> string
)
```

### Zipper.selectorAST (static method)
define the css selector syntax for AST
```
return {
    attr: 'lex' for 'Name' or 'value' for '~Value',
    selector: 'key'
}
```

**sample**
```
'A B' matches the inner node of {
    lex: 'A',
    leaves: [
        {lex: 'B'} <- get this
    ]
}

'A ~B' matches the inner node of {
    lex: 'A',
    leaves: [
        {value: 'B'} <- get this
    ]
}
```

### Zipper.findParent (static method)
find the specific parent node in recursively
```
Zipper.findParent(
    parent node attributes, -> object
    base node -> object
)
```