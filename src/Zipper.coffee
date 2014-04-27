if typeof self == 'undefined'
    ulti = require './ulti.js'
else
    ulti = self.ulti


Zipper = (tree) ->
    @tree = tree
    @curr_node = @tree
    @

Zipper::up = ->
    @curr_node = @curr_node.parent
    @

Zipper::down = (selector) ->
    @curr_node = (Zipper.select @curr_node, selector)[0]
    @

Zipper::parent = (attrs={}) ->
    Zipper.findParent attrs, @curr_node

Zipper::node = ->
    @curr_node




Zipper.select = (parent_node, selector) ->
    ret = []

    selector_arr = selector.split /\s+/

    walk = (node, detect, arr) ->
        if node.leaves
            for leaf in node.leaves
                walk leaf, detect, arr

        if detect node
            arr.push node

    selectorAttr = Zipper.selectorAST

    detector = (selector) ->
        sa = selectorAttr selector
        (node) -> node[sa.attr] == sa.selector

    last_selector = selector_arr.pop()

    if not last_selector
        return ret

    walk parent_node, detector(last_selector), ret

    while last_selector = selector_arr.pop()
        if not last_selector or not ret.length
            break

        new_ret = []
        sa = selectorAttr last_selector

        for node in ret
            attrs = {}
            attrs[sa.attr] = last_selector
            parent_node = Zipper.findParent attrs, node
            if parent_node
                new_ret.push node

        ret = new_ret

    ret

Zipper.selectorAST = (selector) ->
    attr = 'lex'
    if selector[0] == '~'
        selector = selector.slice 1
        attr = 'value'

    attr: attr, selector: selector

Zipper.findParent = (attrs={}, node) ->
    ret = null
    while curr_node = node.parent
        if not curr_node
            break

        match = true
        for attr of attrs
            if curr_node[attr] != attrs[attr]
                match = false

        if match
            ret = curr_node
            break

        node = curr_node

    ret

# specific for syntax node
Zipper.rebuildParent = (syntax_node, parent, mix_map) ->
    if typeof syntax_node.parent == 'string'
        syntax_node.parent = parent

    if mix_map and syntax_node['__MixMapID__']
        mix_map.refs[syntax_node['__MixMapID__']] = syntax_node

    if syntax_node.leaves
        for leaf in syntax_node.leaves
            Zipper.rebuildParent leaf, syntax_node, mix_map


if typeof self == 'undefined'
    module.exports.Zipper = Zipper
else
    self.Zipper = Zipper

log = ->
#return
log = ulti.log