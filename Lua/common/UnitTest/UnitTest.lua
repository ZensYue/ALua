
---@class UnitTest
local UnitTest = {}

--- 创建单元测试列表
--- table 自带有 Run 方法。可以直接调用，外部不要重写Run方法
---@param copyTb table 数据原始表,外部调用不要填写。用于内部引用
---@param funcList table 方法列表,外部调用不要填写。用于内部引用
---@return table
function UnitTest.New(copyTb,funcList)
    copyTb = copyTb or {}
    if not funcList then
        funcList = {}
        copyTb.__func_list = funcList
    end

    local t = setmetatable({},{
        __index = copyTb,
        __newindex = function(t,k,v)
            if type(v) == "table" then
                rawset(t,k,UnitTest.New(v,funcList))
            else
                -- t[k] = v
                rawset(t,k,v)
                if type(v) == "function" then
                    funcList[#funcList+1] = {name = k,func = v}
                end
            end
        end
    })

    rawset(t,"Run",function()
        UnitTest.Run(t)
    end)
    t.Debug = true
    return t
end

---@private
function UnitTest.Run(unit)
    if not unit.__func_list then
        return
    end
    for i = 1, #unit.__func_list do
        local funcInfo = unit.__func_list[i]
        if unit.Debug then
            print("===========start call " .. funcInfo.name or "")
            funcInfo.func()
            print("===========success call " .. funcInfo.name or "")
            print("\n\n")
        else
            funcInfo.func()
        end
    end
end

return UnitTest