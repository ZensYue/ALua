--------------------------------------------------------------------------------
--      Copyright (c) 2022 , ZensYue ZensYue@163.com
--      All rights reserved.
--      Use, modification and distribution are subject to the "MIT License"
--------------------------------------------------------------------------------

local setmetatable = setmetatable
local ipairs = ipairs
-- 递归调用构造函数
local function ctor(cls, obj, ...)
    if cls.super then
        ctor(cls.super, obj, ...)
    end
    if rawget(cls,"ctor") then
        cls.ctor(obj, ...)
    end
end

--析构函数（假的），得手动调用
local function dctor(this)
    assert(this,"Call Delete use ':'")
    if this.is_dctored then
        return
    end
    this.is_dctored = true
    local cls = this.classtype
    while cls ~= nil do
        if rawget(cls,"dctor") then
            cls.dctor(this)
        end
        cls = cls.super
    end
end

--- New,__New,Delete,__Delete 是关键字,不能用于变量,不要重写
--- 支持多继承，第一个为主继承
function Aclass(clsname,...)
    local supers = {...}
    local cls = { classname = clsname,supers = supers }
    if supers then
        local super = supers[1]
        cls.super = super
        setmetatable(cls, { __index = function(t, k)
            for i = 1, #supers do
                local v = supers[i]
                local ret = v[k]
                if ret ~= nil then
                    --- 内存换时间.如果 需要支持热重载，这里不能开启
                    -- if i == 1 then
                    --     t[k] = ret
                    -- end
                    return ret
                end
            end
        end })
    end
    cls.New = function(...)
        local self = setmetatable({ classtype = cls,is_dctored = false }, { __index = cls })
        ctor(cls,self, ...)
        
        return self
    end

    cls.Delete = dctor
    
    return cls
end


function ABaseClass(clsname,...)
    local cls = { classname = clsname,super = super }
    if super then
        setmetatable(cls, { __index = function(t, k)
            local ret = super[k]
            if ret ~= nil then
            	-- 内存换时间
            	-- t[k] = ret
                return ret
            end
        end })
    end
    cls.New = function(...)
        local self = setmetatable({ classtype = cls }, { __index = cls })
        ctor(cls,self, ...)
        return self
    end
    return cls
end

--- 可用于热重载,写法有一定要求。
--- 尽量不要使用闭包。已经持有闭包的变量,很难热重载。
--- 一个文件只能有一个class
function reimport(path)
    if not package.loaded[path] then
        return require(path)        
    end
	local oldmodule = require(path)
	package.loaded[path]=nil
	local newmodule = require(path)
    if not oldmodule then
        return
    end
    local newType = type(oldmodule)
    if newType == "table" and newType == type(oldmodule) then
        for k,v in pairs(newmodule) do
            oldmodule[k]= v
        end
    end
	package.loaded[path]= oldmodule
    return oldmodule
end