## Ulti

Ulti is a set of helpers

### Definition

#### ulti.uniquePush
push element to array if element is not in array
```
ulti.uniquePush(
    array, -> array
    element -> object
)
```

#### ulti.uniqueConcat
uniquePush elements of array to another
```
ulti.uniqueConcat(
    form array, -> array
    to another -> array
)
```

#### ulti.makeCombination
make combination of elements of array

```
array = [[1,2], [3,4]]

    -> ulti.makeCombination ->

result = [[1,3], [1,4], [2,3], [2,4]]
```

```
ulti.makeCombintaion(
    one level nested array -> array
)
```

#### ulti.stripEmptyOfList
strip empty of list recursively
```
ulti.stripEmptyOfList(
    list -> array
)
```


### utli.objDotAccessor
access object with string path
```
A = {foo: {bar: 1}}

ulti.objDotAccessor(A, 'foo.bar') // get 1
```

```
ulti.objDotAccessor(
    object, -> object
    path string with dot -> string
)
```

#### ulti.toObjString
make JSON.stringify compatible with circulate reference

```
ulti.toObjString(
    object with circulate reference -> object
    format indent -> number
)
```

#### ulti.dump
dump object to ~/.dawnjs/cache/ or indexedDB of WebBrowser

```
ulti.dump(
    type of object, -> string
    unique file key name, -> string
    object -> object
)
```


#### ulti.load
load object from ~/.dawnjs/cache/ or indexedDB of WebBrowser

```
ulti.load(
    type of object, -> string
    unique file key name, -> string
    callback with returned object -> function
)
```

#### ulti.existLocalCache
detect if exist dumped cache from ~/.dawnjs/cache/

```
ulti.existLocalCache(
    type of object, -> string
    unique file key name -> string
)
```


#### ulti.log
log method for debug

```
ulti.log(
    content, -> object
    mark ,-> string
    indent (default 4) -> number
)
```

#### ulti.stringEqual
detect if two object if equal in string form
```
ulti.stringEqual(
    source object, -> object
    target object, -> object
    mark -> string
)
```

#### ulti.jsonClone
clone object with JSON.stringify and JSON.parse
```
ulti.jsonClone(
    object -> object
)
```

#### ulti.fileWalk
walk directory recursively with handler
```
ulti.fileWalk(
    root directory path, -> string
    handler -> function
)
```