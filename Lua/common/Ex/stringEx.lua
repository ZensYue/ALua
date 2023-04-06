--------------------------------------------------------------------------------
--      Copyright (c) 2022 , ZensYue ZensYue@163.com
--      All rights reserved.
--      Use, modification and distribution are subject to the "MIT License"
--------------------------------------------------------------------------------


local string = string

function string.safesplit(splitstr, sep)
    local t = {}
    if sep then
        local p
        local len = string.len(sep)
        if len > 1 and sep ~= string.rep(".", len) and not sep:find("%%") then
            p = "(.-)" .. sep
            splitstr = splitstr .. sep
        else
            p = "([^" .. sep .. "]+)"
        end
        for str in splitstr:gmatch(p) do
            if str ~= "" then
                table.insert(t, str)
            end
        end
    end
    return t
end

function string.split(splitstr, sep)
    splitstr = tostring(splitstr)
    local b, ret = pcall(string.safesplit, splitstr, sep)
    if b then
        return ret
    else
        error("splitstr:", splitstr, ",sep:", sep, ",errmsg:", ret)
        return {}
    end
end

string.oriformat = string.format
function string.format(s, ...)
    local list = {}
    local len = select("#", ...)
    for i = 1, len do
        local v = select(i, ...)
        if v == nil or type(v) == "boolean" then
            table.insert(list, tostring(v))
        else
            table.insert(list, v)
        end
    end
    return string.oriformat(s, unpack(list))
end

function string.startswith(s, starts)
    if #starts > #s then
        return false
    end
    for i = 1, #starts do
        if string.byte(s, i) ~= string.byte(starts, i) then
            return false
        end
    end
    return true
end

function string.endswith(s, ends)
    local lenS = #s
    local lenEnds = #ends
    if lenEnds > lenS then
        return false
    end
    local offset = lenS - lenEnds
    for i = 1, lenEnds do
        if string.byte(s, offset + i) ~= string.byte(ends, i) then
            return false
        end
    end
    return true
end

--非正则替换
function string.replace(s, pat, repl, n)
    local list = { "(", ")", ".", "%", "+", "-", "*", "?", "[", "^", "$" }
    for k, v in ipairs(list) do
        pat = string.gsub(pat, "%" .. v, "%%" .. v)
    end
    return string.gsub(s, pat, repl, n)
end

--获取UTF8字符串长度
--@param str string 目标字符串
--@return number 字符长度
function string.utfStrlen(str)
    local len = #str
    local left = len
    local cnt = 0
    local arr = { 0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc }
    while left ~= 0 do
        local temp = string.byte(str, -left)
        local i = #arr
        while arr[i] do
            if temp >= arr[i] then
                left = left - i
                break
            end
            i = i - 1
        end
        cnt = cnt + 1
    end
    return cnt
end

function string.utf8list(input)
    local len = string.len(input)
    local left = 1
    local cnt = 0
    local arr = { 0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc }
    local t = {}
    local last_len = 1
    while left <= len do
        local tmp = string.byte(input, left)
        local i = #arr
        while arr[i] do
            if tmp >= arr[i] then
                left = left+i-1
                break
            end
            i = i - 1
        end
        local s = string.sub(input, last_len,left)
        left = left + 1
        last_len = left
        table.insert(t, s)
        cnt = cnt + 1
    end
    return t
end

function string.getutftable(str)
    local t = {}
    for uchar in string.gmatch(str, "[%z\1-\127\194-\244][\128-\191]*") do
        t[#t + 1] = uchar
    end
    return t
end

--判断是否存在非法字符
--@param s 目标字符串
--@return bool
function string.isIllegal(s)
    local len = #s
    local count = 0
    for k = 1, len do
        local c = string.byte(s, k)
        if not c then
            break
        end
        if (c >= 48 and c <= 57) or (c >= 65 and c <= 90) or (c >= 97 and c <= 122) then
            count = count + 1
        elseif c >= 228 and c <= 233 then
            local c1 = string.byte(s, k + 1)
            local c2 = string.byte(s, k + 2)
            if c1 and c2 then
                local a1, a2, a3, a4 = 128, 191, 128, 191
                if c == 228 then
                    a1 = 184
                elseif c == 233 then
                    a2, a4 = 190, c1 ~= 190 and 191 or 165
                end
                if c1 >= a1 and c1 <= a2 and c2 >= a3 and c2 <= a4 then
                    k = k + 2
                    count = count + 3
                end
            end
        end
    end
    if count ~= len then
        --存在不是中文,字母,数字 字符
        return false
    end
    return true
end

--string.eval("a+b", {a=1, b=2})
-- function string.eval(s, t)
--     local f = loadstring(string.format("do return %s end", s))
--     setfenv(f, t)
--     return f()
-- end

local numberConvertFormat = nil

function string.SetNumberConvertFormat(language)
    if language == "en" then
        numberConvertFormat = {
            { value = 1000000000000, show = "T", f = 2, check_v = 1000000000000 }, -- 万亿
            { value = 1000000000, show = "B", f = 2, check_v = 1000000000 }, -- 十亿
            { value = 1000000, show = "M", f = 2, check_v = 10000000 },       -- 千万 显示百万
            { value = 1000000, show = "M", f = 1, check_v = 1000000 },       -- 百万
            { value = 1000, show = "K", f = 1, check_v = 1000 },             -- 千
        }
    end
end

--[[
    f 保留几位小数 百万亿以上保留0位小数 十万亿以上保留1位小数 万亿以上保留2位小数
--]]
local defalutNumberConvertFormat = {
    --{ value = 1000000000000, show = "万亿", f = 0, check_v = 100000000000000 },
    --{ value = 1000000000000, show = "万亿", f = 1, check_v = 10000000000000 },
    { value = 1000000000000, show = "万亿", f = 2, check_v = 1000000000000 },
    --{ value = 100000000, show = "亿", f = 0, check_v = 10000000000 },
    --{ value = 100000000, show = "亿", f = 1, check_v = 1000000000 },
    { value = 100000000, show = "亿", f = 2, check_v = 100000000 },
    --{ value = 10000, show = "万", f = 0, check_v = 1000000 },
    --{ value = 10000, show = "万", f = 1, check_v = 100000 },
    { value = 10000, show = "万", f = 2, check_v = 10000 },
}

--转换函数 超过10 000   显示 1万
function string.numberConvert(num)
    local size = nil
    num = tryToInt(num)
    local check_tab = numberConvertFormat or defalutNumberConvertFormat
    for i = 1, #check_tab do
        local info = check_tab[i]
        if info and num >= info.check_v then
            local n, f
            local f_v = Mathf.Pow(10, info.f)
            num = num / info.value * f_v
            num = math.round(num)
            local tab = string.split(tostring(num / f_v), ".")
            n, f = tab[1] or 0, tab[2] or 0
            if tonumber(f) == 0 then
                if size then
                    return n .. string.format("<size=%s>%s</size>", size, info.show)
                else
                    return n .. info.show
                end
            else
                if tonumber(f) % 10 <= 1e-05 then
                    f = tonumber(f) * 0.1
                end
                if size then
                    return string.format("%d.%s<size=%s>%s</size>", n, f, size, info.show)
                else
                    return string.format("%d.%s%s", n, f, info.show)
                end
            end
        end
    end
    return num
end

--阿拉伯数字转中文
function string.number2text(n, isbig)
    local t = { "一", "二", "三", "四", "五", "六", "七", "八", "九", "零" }
    local bigt = { "壹", "贰", "叁", "肆", "伍", "陆", "柒", "捌", "玖", "零" }
    if isbig then
        return (bigt[n] or "")
    else
        return (t[n] or "")
    end
end

--获取固定长度字符串，超出长度都用……替代
function string.gettitle(str, size, sPattern)
    local sPattern = sPattern or "……"
    local t = string.getutftable(str)
    local result = {}
    local cnt = 0
    for k, v in pairs(t) do
        if string.byte(v) > 0xc0 then
            cnt = cnt + 2
        else
            cnt = cnt + 1
        end
        if cnt <= size then
            table.insert(result, v)
        else
            table.insert(result, sPattern)
            break
        end
    end
    return table.concat(result, "")
end

function string.findstr(str, starget)
    local amountstr = string.len(str)
    local amounttarget = string.len(starget)
    if amounttarget > amountstr then
        return false
    end
    for i = 1, amountstr do
        local flag = true
        for j = 1, amounttarget do
            if string.sub(str, i - 1 + j, i - 1 + j) ~= string.sub(starget, j, j) then
                flag = false
            end
        end
        if flag then
            return i
        end
    end
end

function string.getstringdark(str)
    str = tostring(str) or ""
    if str ~= "" then
        str = string.gsub(str, "#%a", "#FFFFFF")
    end
    return str
end

function string.IsNilOrEmpty(str)
    return (str == nil) or (str == "")
end

function string.isempty(str)
    return string.IsNilOrEmpty(str)
end

local function tochinesenumber(num)
    if num == nil then
        return
    end
    local chinese_num = { "零", "一", "二", "三", "四", "五", "六", "七", "八", "九" }
    local tem_name_list = { "", "十", "百", "千", "万" }
    num = tonumber(num)
    local num_str = tostring(num)
    local num_len = string.len(num_str)
    local final_content = {}
    local cell_content = ""
    for i = 1, num_len do
        if string.sub(num_str, i, i) == "0" then
            if num_len > 1 and (i == num_len or tonumber(string.sub(num_str, i + 1, num_len)) == 0) then
                --尾数的零不显示
                cell_content = ""
            else
                cell_content = chinese_num[1]
            end
        else
            if num >= 10 and num < 20 and i == 1 then
                cell_content = tem_name_list[num_len - i + 1]
            else
                cell_content = chinese_num[string.sub(num_str, i, i) + 1] .. tem_name_list[num_len - i + 1]
            end
        end
        if i == 1 or cell_content ~= chinese_num[1] or final_content[i - 1] ~= chinese_num[1] then
            --避免中间出现重复的零
            table.insert(final_content, cell_content)
        end
    end
    return table.concat(final_content)
end

function string.tochinesenumber(num)
    local formatted = tostring(num)
    local k
    local count = 0
    local final_content = ""
    while true do
        local cur_format
        formatted, k = string.gsub(
                formatted,
                "^(-?%d+)(%d%d%d%d)",
                function(s1, s2)
                    cur_format = s2
                    return s1
                end
        )
        if k == 0 then
            break
        end
        if count > 0 and tonumber(cur_format) > 0 then
            if count % 2 == 1 then
                final_content = "万" .. final_content
            else
                final_content = "亿" .. final_content
            end
        end
        count = count + 1
        final_content = tochinesenumber(cur_format) .. final_content
    end
    if formatted ~= "" then
        if count > 0 then
            if count % 2 == 1 then
                final_content = "万" .. final_content
            else
                final_content = "亿" .. final_content
            end
        end
        final_content = tochinesenumber(formatted) .. final_content
    end
    return final_content
end


function string.tobool(str)
    local t = {
        ["true"] = true,
        ["false"] = false,
    }
    local flag = t[string.lower(str)]
    return flag
end