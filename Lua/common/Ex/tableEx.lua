--------------------------------------------------------------------------------
--      Copyright (c) 2022 , ZensYue ZensYue@163.com
--      All rights reserved.
--      Use, modification and distribution are subject to the "MIT License"
--------------------------------------------------------------------------------

unpack = unpack or table.unpack

function table.dump(t, name)
    local LINEW = 80
    local function p(o, name, indent, send)
        local s = ""
        s = s .. string.rep("\t", indent)
        if name ~= nil then
            if type(name) == "number" then
                name = string.format("[%d]", name)
            else
                name = tostring(name)
                if indent ~= 0 then
                    if not string.match(name, "^[A-Za-z_][A-Za-z0-9_]*$") then
                        name = string.format("[\"%s\"]", name)
                    end
                end
            end
            s = s .. name .. "="
        end
        if type(o) == "table" then
            s = s .. "{"
            local temp = ""
            local keys = {}
            for k, v in pairs(o) do
                table.insert(keys, k)
            end
            pcall(function()
                table.sort(keys)
            end)
            for i, k in ipairs(keys) do
                local v = o[k]
                temp = temp .. p(v, k, indent + 1, ",")
            end

            local temp2 = string.gsub(temp, "[\n\t]", "")
            if #temp2 < LINEW then
                temp = temp2
            else
                s = s .. "\n"
                temp = temp .. string.rep("\t", indent)
            end
            s = s .. temp .. "}" .. send .. "\n"
        else
            if type(o) == "string" then
                o = "[[" .. o .. "]]"
            elseif o == nil then
                o = "nil"
            end
            s = s .. tostring(o) .. send .. "\n"
        end
        return s
    end
    return p(t, name, 0, "")
end

function table.tostringlist(t,maxlayer,name)
    local tableDict = {}
    local layer = 0
    maxlayer = maxlayer or 999
    local function cmp(t1, t2)
        return tostring(t1) < tostring(t2)
    end
    local function table_r (t, name, indent, full, layer)
        local id = not full and name or type(name) ~= "number" and tostring(name) or '[' .. name .. ']'
        local tag = indent .. id .. ' = '
        local out = {}  -- result
        if type(t) == "table" and layer < maxlayer then
            if tableDict[t] ~= nil then
                table.insert(out, tag .. '{} -- ' .. tableDict[t] .. ' (self reference)')
            else
                tableDict[t] = full and (full .. '.' .. id) or id
                if next(t) then
                    -- Table not empty
                    table.insert(out, tag .. '{')
                    local keys = {}
                    for key, value in pairs(t) do
                        table.insert(keys, key)
                    end
                    table.sort(keys, cmp)
                    for i, key in ipairs(keys) do
                        local value = t[key]
                        local list = table_r(value, key, indent .. '    ', tableDict[t], layer + 1)
                        -- table.insert(out, list)
                        table.insertlist(out,list)
                    end
                    table.insert(out, indent .. '}')
                else
                    table.insert(out, tag .. '{}')
                end
            end
        else
            local val = type(t) ~= "number" and type(t) ~= "boolean" and '"' .. tostring(t) .. '"' or tostring(t)
            table.insert(out, tag .. val)
        end
        return out
    end
    return table_r(t, name or 'Table', '', '', layer)
end

function table.tostring(t, maxlayer, name)
    local out = table.tostringlist(t, maxlayer, name)
    return table.concat(out, '\n')
end

function table.print(t, name, maxlayer)
    print(table.tostring(t, maxlayer, name))
end

function table.printlines(t,name,maxlayer)
    print("table.printlines ",name or ""," start")
    local t = table.tostringlist(t, maxlayer, name)
    for i = 1, #t do
        print(t[i])
    end
    print("table.printlines ",name or ""," end")
end

function table.clear(t)
    local k,_ = next(t)
    while k do
        t[k] = nil
        k,_ = next(t)
    end
end

function table.index(tab, element)
    if not tab then
        return
    end
    for k, value in pairs(tab) do
        if value == element then
            return k
        end
    end
end

function table.keys(t)
    local keys = {}
    for k, v in pairs(t) do
        table.insert(keys, k)
    end
    return keys
end

function table.key(t, v)
    for k1, v1 in pairs(t) do
        if v1 == v then
            return k1
        end
    end
end

function table.safeget(root, ...)
    local len = select("#", ...)
    local v = root
    for i = 1, len do
        local key = select(i, ...)
        v = v[key]
        if not v then
            return
        end
    end
    return v
end

function table.safeinsert(root, v, ...)
    local len = select("#", ...)
    local parent = root
    for i = 1, len do
        local key = select(i, ...)
        if not parent[key] then
            parent[key] = {}
        end
        parent = parent[key]
    end
    table.insert(parent, v)
end

function table.safeset(root, v, ...)
    local len = select("#", ...)
    local parent = root
    for i = 1, len do
        local key = select(i, ...)
        if i == len then
            parent[key] = v
        else
            if not parent[key] then
                parent[key] = {}
            end
            parent = parent[key]
        end
    end
end

function table.values(t)
    local values = {}
    for k, v in pairs(t) do
        table.insert(values, v)
    end
    return values
end

function table.count(t)
    local count = 0
    for k, v in pairs(t) do
        count = count + 1
    end
    return count
end

function table.copy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return new_table
    end
    return _copy(object)
end

function table.deepcopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local newObject = {}
        lookup_table[object] = newObject
        for key, value in pairs(object) do
            newObject[_copy(key)] = _copy(value)
        end
        return setmetatable(newObject, getmetatable(object))
    end
    return _copy(object)
end

function table.equal(t1, t2)
    if t1 == t2 then
        return true
    end
    if type(t1) == "table" and type(t2) == "table" then
        if table.count(t1) ~= table.count(t2) then
            return false
        end
        for k, v in pairs(t1) do
            if not table.equal(v, t2[k]) then
                return false
            end
        end
        return true
    end
    return false
end

function table.list2dict(t, key)
    local dict = {}
    if not t then
        return dict
    end
    for i, v in ipairs(t) do
        dict[v[key]] = v
    end
    return dict
end

function table.dict2list(t, sortkey, reverse)
    local function sortfunc(v1, v2)
        if reverse then
            return v2[sortkey] < v1[sortkey]
        else
            return v1[sortkey] < v2[sortkey]
        end
    end
    local list = {}
    for k, v in pairs(t) do
        table.insert(list, v)
    end
    if sortkey then
        table.sort(list, sortfunc)
    end
    return list
end

function table.extend(t1, t2)
    for k, v in ipairs(t2) do
        table.insert(t1, v)
    end
    return t1
end

function table.update(t1, t2)
    for k, v in pairs(t2) do
        t1[k] = v
    end
    return t1
end

function table.merge(...)
    local t = {}
    local list = { ... }
    for i, dict in ipairs(list) do
        for k, v in pairs(dict) do
            t[k] = v
        end
    end
    return t
end

function table.slice(t, iStart, iEnd)
    local temp = {}
    if iStart <= iEnd then
        if #t < iStart then
            temp = t
        else
            for i = iStart, iEnd do
                local o = t[i]
                if o then
                    table.insert(temp, o)
                else
                    break
                end
            end
        end
    end
    return temp
end

function table.randomvalue(t)
    local keys = table.keys(t)
    local idx = math.Random(1, #keys)
    return t[keys[idx]]
end

function table.randomkey(t)
    local keys = table.keys(t)
    local idx = math.Random(1, #keys)
    return keys[idx]
end

function table.intersect(t1, t2)
    local list = {}
    for _, v in ipairs(t1) do
        if table.index(t2, v) ~= nil then
            table.insert(list, v)
        end
    end
    return list
end

function table.reverse(tab)
    local size = #tab
    local newTable = {}
    for i, v in ipairs(tab) do
        newTable[size + 1 - i] = v
    end
    return newTable
end

function table.range(iStart, iEnd)
    local list = {}
    for i = iStart, iEnd do
        table.insert(list, i)
    end
    return list
end

function table.isempty(tab)
    return not tab or _G.next(tab) == nil
end

--迭代器 key由小到大遍历
--key 为number
function table.pairsByKey(tab)
    local t = table.keys(tab)
    local function sortFunc(a, b)
        return a < b
    end
    table.sort(t, sortFunc)
    local i = 0
    return function()
        i = i + 1
        return t[i], tab[t[i]]
    end
end

--迭代器 key由大到小遍历
function table.pairsByKeyMax(tab)
    local t = table.keys(tab)
    local function sortFunc(a, b)
        return a > b
    end
    table.sort(t, sortFunc)
    local i = 0
    return function()
        i = i + 1
        return t[i], tab[t[i]]
    end
end

-- 随机遍历
function table.pairByRandom(tab)
    local t = table.keys(tab)
    return function()
        if #t == 0 then
            return nil
        end
        local i = math.random(#t)
        local key = t[i]
        local value = tab[t[i]]
        table.remove(t, i)
        return key, value
    end
end

--[[
    @author ZensYue
    @des    递归合并
    @param1 tab
    @param2 src
    @param3 isThorough 表中表是否要递归合并 默认是要
    @ps     dest     = {x = 10,y = 20}
            src = {x = 11,z = 30}
        使用后得：dest = {x = 11,y = 20,z = 30}
--]]
function table.RecursionMerge(dest, src, isThorough)
    if type(dest) ~= "table" or type(src) ~= "table" then
        return
    end
    isThorough = isThorough ~= nil and true or isThorough
    local function recursion(value1, value2)
        for k, v in pairs(value2) do
            if isThorough and type(v) == "table" then
                value1[k] = value1[k] or {}
                recursion(value1[k], v)
            else
                value1[k] = v
            end
        end
    end
    recursion(dest, src)
end

--- 通用排序方法，支持多种条件和特殊判断回调
---@param tab table 数组类型的table
---@param params string[] 排序的字段列表
---@param isOrder boolean 是否为正序(小到大)，默认是
---@param func fun(t1:any,t2:any,key:string):boolean|nil 排序方法，默认可以不传，不传默认通用条件，用正反序排序。回调必须有返回值,如果返回 nil 继续下一个条件
---@return table
function table.sortFunc(tab, params, isOrder, func)
    isOrder = isOrder == nil and true or isOrder

    local function recursionSort(t1, t2, params, index, isOrder, func)
        index = index or 1
        local key = params[index]
        if not key then
            return false
        end
        if func then
            -- 结果为空，表示没有结果，继续用下一个条件作判断
            local r = func(t1, t2, key)
            if r == nil then
                return recursionSort(t1, t2, params, index + 1, isOrder, func)
            else
                return r
            end
        end
        local v1 = t1[key]
        local v2 = t2[key]
        if v1 == v2 then
            return recursionSort(t1, t2, params, index + 1, isOrder, func)
        end
        if not v1 then
            return false
        end
        if not v2 then
            return true
        end
        if isOrder then
            return v1 < v2
        else
            return v1 > v2
        end
    end

    local function sortfunction(t1, t2)
        return recursionSort(t1, t2, params, nil, isOrder, func)
    end
    table.sort(tab, sortfunction)
    return tab
end

function table.walk(tab, fn, start_index, end_index)
    start_index = start_index or 1
    end_index = end_index or #tab
    for i = start_index, end_index do
        local v = tab[i]
        fn(i, v)
    end
end

--[[
    @author ZensYue
    @des    根据index删除多个，只支持数组
    @param1 array   table
    @param2 array   del_tab  数组，value由小到大
--]]
function table.remove_array_indexlist(array, indexlist)
    local count = 0
    local len = #indexlist
    for i = 1, len do
        local index = indexlist[i] - count
        table.remove(array, index)
        count = count + 1
    end
end

--- 是否包含指定属性值
---@param list table
---@param attributekey string|number
---@param value any
---@return boolean
function table.iscontainattribute(list, attributekey, value)
    return table.getattributeindex(list, attributekey, value) ~= nil
end

--- 获取指定属性值 key
---@param list table
---@param attributekey string|number
---@param value any
---@return number|string table key
function table.getattributeindex(list, attributekey, value)
    for i, v in pairs(list) do
        if type(v) == "table" and v[attributekey] == value then
            return i
        end
    end
    return nil
end

--- 获取指定属性值 value
---@param list table
---@param attributekey string|number
---@param value any
---@return number|string table key
function table.getattributevalue(list, attributekey, value)
    for i, v in pairs(list) do
        if type(v) == "table" and v[attributekey] == value then
            return v
        end
    end
    return nil
end

--- list 2 的元素插入到list 1
---@param list1 table
---@param list2 table
---@param reversal boolean 是否反转在首位插入 不填默认在尾部插入
---@param start_index number 开始序号    不填默认1
---@param end_index number 结束序号    不填默认#list2
function table.insertlist(list1, list2, start_index, end_index, reversal)
    start_index = start_index or 1
    end_index = end_index or #list2
    for i = start_index, end_index do
        local v = list2[i]
        if v then
            if reversal then
                table.insert(list1, 1, v)
            else
                table.insert(list1, v)
            end
        end
    end
    return list1
end

function table.indexof(array, value, begin)
    for i = begin or 1, #array do
        if array[i] == value then
            return i
        end
    end
    return false
end

function  table.readOnly(tbl)
    local travelled_tables = {}
    local function __read_only(obj,root)
        if not travelled_tables[obj] then
            local tbl_mt = getmetatable(obj)
            if not tbl_mt then
                tbl_mt = {}
                setmetatable(obj, tbl_mt)
            end

            local proxy = tbl_mt.__read_only_proxy
            if not proxy then
                proxy = {}
                tbl_mt.__read_only_proxy = proxy
                local proxy_mt = {
                    __index = obj,
                    __newindex = function(t, k, v)
                        -- error("error write to a read-only table with key = " ..tostring(root) .."." ..tostring(k))
                        print("error write to a read-only table with key = " ..tostring(root) .."." ..tostring(k))
                    end,
                    __pairs = function(t)
                        return pairs(obj)
                    end,
                    __len = function(t)
                        return #obj
                    end,
                    __read_only_proxy = proxy
                }
                setmetatable(proxy, proxy_mt)
            end
            travelled_tables[obj] = proxy
            for k, v in pairs(obj) do
                if type(v) == "table" then
                    obj[k] = __read_only(v,root .."."..tostring(k))
                end
            end
        end
        return travelled_tables[obj]
    end
    return __read_only(tbl,"")
end

function table.dirty(tbl)
    local tab = {__dirty=false}
    rawset(tab,"__refresh",function(bo)
        if bo == nil then
            bo = false
        end
        rawset(tab,"__dirty",bo)
    end)
    rawset(tab,"__data",function()
        return tbl
    end)

    local function _dirty(obj,metatable)
        --- 主要用于__index取值为table的情况,必须拿到处理后的table
        local recordTbl = {}
        metatable = metatable or {}
        setmetatable(metatable,{
            __index = function(_,k)
                return recordTbl[k] or obj[k]
            end,
            __newindex = function(t,k,v)
                if type(v) == "table" then
                    if table.equal( tbl[k],v) then
                        return
                    end
                    obj[k]=v
                    rawset(recordTbl,k,_dirty(obj[k]))
                else
                    if obj[k] == v then
                        return
                    end
                    rawset(recordTbl,k,nil)
                    obj[k]=v
                end
                rawset(tab,"__dirty",true)
            end,
            __pairs = function(t)
                return pairs(obj)
            end,
            __len = function(t)
                return #obj
            end,
        })
        for k, v in pairs(obj) do
            if type(v) == "table" then
                rawset(recordTbl,k,_dirty(v))
            end
        end
        return metatable
    end
    return _dirty(tbl,tab)
end

function table.debug(obj,indexfn,newindexfn)
    local tbl = {}
    return setmetatable({},{
        __index = function(_,k)
            if indexfn then
                indexfn(k)
            end
            return tbl[k] or obj[k]
        end,
        __newindex = function(_, k, v)
            if newindexfn then
                newindexfn(k,v)
            end
            rawset(tbl, k, v)
        end
    })
end