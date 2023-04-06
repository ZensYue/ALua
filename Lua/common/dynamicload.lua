--------------------------------------------------------------------------------
--      Copyright (c) 2022 , ZensYue ZensYue@163.com
--      All rights reserved.
--      Use, modification and distribution are subject to the "MIT License"
--------------------------------------------------------------------------------

--- 动态加载模块
--- 可用于动态加载配置表或者配置表的子表。

local setmetatable = setmetatable

---@class dynamicload
local dynamicload = {}
dynamicload.__index = dynamicload

dynamicload.__call = function(this,path)
    local t = setmetatable({}, {__index = this})
	t:ctor(path)
	return t
end

function dynamicload:ctor(path)
	self.m_path = path
    self.tables = {}
    ---@type fun():number
    self.m_time_fun = nil

    self.m_sub_tables = {}
end

---@param fun fun():number 方法需要返回当前时间
--- 设置检测方法
function dynamicload:set_timefun(fun)
    assert(fun() ~= nil,"set_timefn fn must have return value!")
    self.m_time_fun = fun
end

--- 返回动态加载的table
function dynamicload:get_table()
	local t = {}
	setmetatable(t, {
        __index= function (t, k)
            local info = rawget(self.tables, k)
            local time = self.m_time_fun and self.m_time_fun() or os.time()
            if not info then
                local path = self.m_path..k
                local rect,module = pcall(require,path)
                if rect then
                    info = {module = module,time = time,path = path,key=k}
                    rawset(self.tables, k, info)
                else
                    error(string.format("not find %s.lua", path))
                end
            else
                info.time = time
            end
            return info.module
        end,
        __newindex = function()
            error("can not add key,the path = " .. self.m_path)
        end
    })
	return t
end

--- 添加sub module动态加载
---@param name string sub module动态加载的名字,比如 data.item[1001] item 就是sub module动态加载的名字
---@param table dynamicload sub module动态加载,不能添加自己
function dynamicload:add_subtable(name,table)
    assert(self ~= table,"can not add self")
    self.m_sub_tables[name] = table
    --- sub table 不释放 时间设置为-1
    local info = {module = table:get_table(),key=name,sub = true}
    rawset(self.tables, name, info)
end

--- 设置检查时间,超过 checktime 没有使用,自动释放表
function dynamicload:set_checktime(checktime)
    self.m_checktime = checktime
    if self.time_id then
        return
    end
    local function step()
        self:update()
    end
    self.time_id = g_Timer:Start(step,1,-1)
end

--- 清除动态table
function dynamicload:clear()
    for _, table in pairs(self.m_sub_tables) do
        table:clear()
    end
    self.tables = {}
    self.m_sub_tables = {}
end

---@private
function dynamicload:stop_check()
    if self.time_id then
        g_Timer:Stop(self.time_id)
        self.time_id = nil
    end
end

---@private
function dynamicload:update()
    local cur_time = self.m_time_fun and self.m_time_fun() or g_Timer:GetTime()
    local remove_tbl
    for key, info in pairs(self.tables) do
        if not info.sub and cur_time > info.time + self.m_checktime then
            remove_tbl = remove_tbl or {}
            remove_tbl[#remove_tbl] = key
        end
    end

    if remove_tbl then
        for _, key in pairs(remove_tbl) do
            self:remove(key)
        end
    end
end

function dynamicload:remove(key)
    local info = rawget(self.tables, key)
    package.loaded[info.path] = nil
    rawset(self.tables,key,nil)

    print("remove ".. self.m_path .. key)
end

return setmetatable({}, dynamicload)