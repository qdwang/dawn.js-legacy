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

    toObjString: (obj, indent = 0) ->
        cache = []
        customStringify = (k, v) ->
            if typeof v == 'object' && v != null
                if v in cache
                    return 'CR -> ' + v.toString()

                cache.push v

            return v

        JSON.stringify obj, customStringify, indent



    dump: (type, obj) ->
        if ulti.indexedDBWrite
            ulti.indexedDBWrite type, obj
        else
            fs = require 'fs'

            key = obj.key
            obj = ulti.toObjString obj

            home = process.env.USERPROFILE or process.env.HOME
            dawnjs_dir = home + '/.dawnjs/'
            cache_dir = dawnjs_dir + 'cache/'

            if not fs.existsSync dawnjs_dir
                fs.mkdirSync dawnjs_dir

            if not fs.existsSync cache_dir
                fs.mkdirSync cache_dir

            fs.writeFile (cache_dir + key + '.' + type), obj

    load: (type, file_key, callback) ->
        if ulti.indexedDBRead
            ulti.indexedDBRead type, file_key, (res) ->
                try
                    res = JSON.parse res
                catch
                    null

                callback res
        else
            fs = require 'fs'
            home = process.env.USERPROFILE or process.env.HOME
            dawnjs_dir = home + '/.dawnjs/'
            cache_dir = dawnjs_dir + 'cache/'
            file_name = cache_dir + file_key + '.' + type

            console.log file_name
            if fs.existsSync file_name
                fs.readFile file_name, null, (err, res) ->
                    try
                        res = JSON.parse res
                    catch
                        null

                    callback res


    log: (x, mark, indent = 4) ->
        surfix = ' - ' + if mark then mark else ''
        result = ulti.toObjString(x, indent) + surfix
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


# indexedDB
(->
    if typeof self == 'undefined' or typeof self.indexedDB == 'undefined'
        return false

    workDB = (type, callback) ->
        db = null

        req = self.indexedDB.open 'dawn.jsDB', 1
        req.onsuccess = (e) ->
            db = req.result
            transaction = db.transaction type, 'readwrite'
            objectStore = transaction.objectStore type
            callback objectStore

        req.onupgradeneeded = (e) ->
            db = event.target.result
            objectStore = db.createObjectStore type, {keyPath: 'key'}

        req.onerror = (e) ->
            ulti.log 'IndexedDB Error: ' + e.target.errorCode

    ulti.indexedDBRead = (type, key, callback) ->
        workDB type, (os) ->
            os.get(key).onsuccess = (e) ->
                callback e.target.result

    ulti.indexedDBWrite = (type, obj, callback) ->
        workDB type, (os) ->
            add_os_req = os.put obj

            add_os_req.onsuccess = (e) ->
                callback and callback e.target.result
)()

#for dump load test
#ulti.dump 'ast', {key: 'abc', query: 'afbcdefg'}
#setTimeout (->
#    ulti.load 'ast', 'abc', (res) ->
#        console.log res
#), 1000

if typeof self == 'undefined'
    for i of ulti
        module.exports[i] = ulti[i]
else
    self.ulti = ulti