## Flow

Flow is a plugin system

## How it works

```
                                combined Arguments
Predefined Arguments -> Plugin1 ------------------> Plugin2 ... -> Arguments(combined with result)
```

**Sample**
```js
args = {arg1: [lex], arg2: 'script'}
flow = new Flow(args)
flow.append([Plugin1.flow, Plugin2.flow, Plugin3.flow])
// flow.next() -> this works step by step
flow.finish()

flow.args // contains arg1, arg2, Plugin1output, Plugin2output
// flow.result('Plugin1output') -> this gets data from flow.args
```

## Definition

### Flow
get instance of Flow
```
flow = new Flow(
    start arguments -> object
    )
```

**Instance Attributes**
```
funcs -> list of functions the flow will run through
args -> the args passing through all the flow functions
```

### flow.append
append plugin flow function
```
flow.append(
    a flow function of plugin -> function
    )
```

### flow.next
invoke the next uninvoked function with last combined arguments
```
flow.next()
```

### flow.finish
invoke all the uninvoked functions
```
flow.finish()
```