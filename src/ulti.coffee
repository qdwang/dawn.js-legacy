ulti =
    uniquePush: (arr, elem) ->
        if elem not in arr
            arr.push elem

    uniqueConcat: (arr, elem_arr) ->
        for i in elem_arr
            ulti.uniquePush arr, i


    makeCombination: (lists) ->
        makeCombinationOfTwo = (last_list, remain_lists) ->
            next_list = remain_lists.shift()

            if next_list == undefined
                return last_list

            ret = []
            for last_item in last_list
                for next_item in next_list
                    ret.push last_item.concat next_item

            makeCombinationOfTwo ret, remain_lists

        copy_lists = lists.slice()
        result = makeCombinationOfTwo (copy_lists.shift().map (x) -> if x instanceof Array then x else [x]), copy_lists


    stripEmptyOfList: (list) ->
        ret = []
        for item, i in list
            if item instanceof Array
                ret.push ulti.stripEmptyOfList item
            else
                if item
                    ret.push item

        ret


    objDotAccessor: (obj, path) ->
        if not path
            return obj

        path_arr = path.split '.'
        ret = obj

        while attr = path_arr.shift()
            ret = ret[attr]

        ret


    log: (x, mark, indent) ->
        surfix = ' - ' + if mark then mark else ''
        cache = []
        customStringify = (k, v) ->
            if typeof v == 'object' && v != null
                if v in cache
                    return 'CR -> ' + v.toString()

                cache.push v

            return v

        result = (JSON.stringify x, customStringify , if indent? then indent else 4) + surfix
        cache = null
        console.log result
        result

    stringEqual: (source, target, unit) ->
        toStr = (data) ->
            if typeof data == 'object'
                cache = []
                customStringify = (k, v) ->
                    if typeof v == 'object' && v != null
                        if v in cache
                            return 'CR -> ' + v.toString()

                        cache.push v
                    return v
                data = JSON.stringify source, customStringify, 0
                cache = null

            data = data.trim().replace /E![\w0-9]+/g, '!ReprMark!'

        result = toStr(source) == toStr(target)
        ulti.log result, unit or ''

    jsonClone: (json_obj) ->
        JSON.parse JSON.stringify json_obj


    diff: (orig_list, mod_list) ->
        orig_list = orig_list.slice()
        mod_list = mod_list.slice()

        len = mod_list.length

        ret = []
#        while (curr_elem = mod_list.shift()) == undefined


if typeof self == 'undefined'
    for i of ulti
        module.exports[i] = ulti[i]
else
    self.ulti = ulti