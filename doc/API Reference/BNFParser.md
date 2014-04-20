## BNF Parser

BNF Parser will generate structure from plain E-BNF definition

## Definition

### BNFGrammar
get instance of BNFGrammar
```
bnf_grammar = new BNFGrammar(
    raw bnf content -> string
)
```

**Instance Attributes**
```
raw_bnf_grammar -> input bnf grammar
bnf grammar pairs -> parsed bnf grammar pairs
```

### bnf_grammar.grammarPrepare
generate grammar structure from plain grammar lines
```
bnf_grammar.grammarPrepare(
    plain grammar lines -> array
)
```

### BNFGrammar.isOneOrMore (static method)
test if the closure end with a '+' mark
```
BNFGrammar.isOneOrMore(
    closure -> string
)
```

### BNFGrammar.removeSpecialMark (static method)
remove the special mark in closure
```
BNFGrammar.removeSpecialMark(
    closure -> string
)
```

### BNFGrammar.hasSpecialMark (static method)
test if the special mark in closure
```
BNFGrammar.hasSpecialMark(
    closure -> string
)
```

### bnf_grammar.makePlainBNF
convert E-BNF to normal BNF
```
bnf_grammar.makePlainBNF(
    stop another round parse -> bool
)
```
