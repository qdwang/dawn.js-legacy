## Util

Util is a set of helpers

### Definition

#### util.uniquePush
push element to array if element is not in array
```
util.uniquePush(
    array, -> array
    element -> object
)
```

#### util.uniqueConcat
uniquePush elements of array to another
```
util.uniqueConcat(
    form array, -> array
    to another -> array
)
```

#### util.makeCombination
make combination of elements of array

```
array = [[1,2], [3,4]]

    -> util.makeCombination ->

result = [[1,3], [1,4], [2,3], [2,4]]
```

```
util.makeCombintaion(
    one level nested array -> array
)
```

#### util.stripEmptyOfList
strip empty of list recursively
```
util.stripEmptyOfList(
    list -> array
)
```


### utli.objDotAccessor
access object with string path
```
A = {foo: {bar: 1}}

util.objDotAccessor(A, 'foo.bar') // get 1
```

```
util.objDotAccessor(
    object, -> object
    path string with dot -> string
)
```

#### util.toObjString
make JSON.stringify compatible with circulate reference

```
util.toObjString(
    object with circulate reference -> object
    format indent -> number
)
```

#### util.dump
dump object to ~/.dawnjs/cache/ or indexedDB of WebBrowser

```
util.dump(
    type of object, -> string
    unique file key name, -> string
    object -> object
)
```


#### util.load
load object from ~/.dawnjs/cache/ or indexedDB of WebBrowser

```
util.load(
    type of object, -> string
    unique file key name, -> string
    callback with returned object -> function
)
```

#### util.existLocalCache
detect if exist dumped cache from ~/.dawnjs/cache/

```
util.existLocalCache(
    type of object, -> string
    unique file key name -> string
)
```


#### util.log
log method for debug

```
util.log(
    content, -> object
    mark ,-> string
    indent (default 4) -> number
)
```

#### util.stringEqual
detect if two object if equal in string form
```
util.stringEqual(
    source object, -> object
    target object, -> object
    mark -> string
)
```

#### util.jsonClone
clone object with JSON.stringify and JSON.parse
```
util.jsonClone(
    object -> object
)
```

#### util.fileWalk
walk directory recursively with handler
```
util.fileWalk(
    root directory path, -> string
    handler -> function
)
```