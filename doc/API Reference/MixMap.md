## MixMap

MixMap is a reference grid system

## How it works

```
If one MixMap has been arranged
    ObjectA.Node1 -> TypeA # All Nodes should be object
    ObjectB.Node2 -> TypeB
    ObjectC.Node3 -> TypeC

Then
                  with TypeB
    ObjectA.Node1 ----------> ObjectB.Node2

                  with TypeC
    ObjectA.Node1 ----------> ObjectC.Node3

                  with TypeA
    ObjectB.Node2 ----------> ObjectA.Node1

                  with TypeC
    ObjectB.Node2 ----------> ObjectC.Node3

                  with TypeA
    ObjectC.Node3 ----------> ObjectA.Node1

                  with TypeB
    ObjectC.Node3 ----------> ObjectB.Node2

```

**Sample**
```
ObjectA = {Node1: []}
ObjectB = {Node2: []}
ObjectC = {Node3: []}

mixmap = new MixMap()
mixmap.arrange(
    ['TypeA', ObjectA.Node1],
    ['TypeB', ObjectB.Node2],
    ['TypeC', ObjectA.Node3]
)
mixmap.get(ObjectB.Node2, 'TypeA') // We get ObjectA.Node1
```


## Definition

### MixMap
get instance of MixMap
```
mixmap = new MixMap()
```
**Instance Attributes**
```
i -> unique id number
ref_map -> place to store reference relations
```

### mixmap.arrange
add reference relation to mixmap
```
mixmap.arrange(
    ['typeA', objectA], -> [string, object]
    ['typeB', objectB],
    ...
)
```

### mixmap.get
get object through it's type and related object
```
mixmap.get(
    related object, -> object
    wanted object type -> string
)
```
