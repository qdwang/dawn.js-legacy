# dawn.js

**General Transpiler implemented in JavaScript**

dawn.js is a source to source compiler implemented in JavaScript(CoffeeScript)

## NPM
```
npm install dawn.js
```

## Built in Features

* Lexical Parser
* Syntax Parser (including AST)
* Symbol Table Generator
* Customizable Plugin System

## Things available to do

* Compile from one language to another language according to the grammar definition
* Implement real autocompletion specific to scopes and objects in Web
* Autocompletion between different languages (like working Javascript with JAVA in Android)
* Accurate refactor
* Handle files in complex structure easily
* Implement amazing editing features form heavy weight editors (VisualStudio, IntellijIDEA...) in light weight editors (Web, SublimeText, Atom...)

## Demo

* [Link](http://dawnjs.org/#demo)

## Tutorial
* Coming soon...

## API Reference
* [Flow](https://github.com/qdwang/dawn.js/blob/master/doc/API%20Reference/Flow.md) - the dawn.js plugin system
* [MixMap](https://github.com/qdwang/dawn.js/blob/master/doc/API%20Reference/MixMap.md) - a reference grid system

* [LexParser](https://github.com/qdwang/dawn.js/blob/master/doc/API%20Reference/LexParser.md) - a parser to tokenize the code script

* [BNFParser](https://github.com/qdwang/dawn.js/blob/master/doc/API%20Reference/BNFParser.md) - generate structure from plain E-BNF definition
* [SyntaxParser](https://github.com/qdwang/dawn.js/blob/master/doc/API%20Reference/SyntaxParser.md) - a parser to generate syntax tree from lex list

* [SymbolTable](https://github.com/qdwang/dawn.js/blob/master/doc/API%20Reference/SymbolTable.md) - a grid system to store specific data for syntax tree

* [Zipper](https://github.com/qdwang/dawn.js/blob/master/doc/API%20Reference/Zipper.md) - a set of utilities to deal with tree structure

* [Ulti](https://github.com/qdwang/dawn.js/blob/master/doc/API%20Reference/Ulti.md) - a set of helpers


## License
MIT