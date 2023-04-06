--------------------------------------------------------------------------------
--      Copyright (c) 2023 , ZensYue ZensYue@163.com
--      All rights reserved.
--      Use, modification and distribution are subject to the "MIT License"
--------------------------------------------------------------------------------

--- 模拟C#的委托

---@class DelegateNode
local DelegateNode = Aclass("DelegateNode")
DelegateNode.__cache_count = 100
classcacheagent(DelegateNode)

--- 设置为true,如果function没有被引用,会gc。慎重开启
DelegateNode.__gc_function = true


function  DelegateNode:ctor(fun,callcount)
    if DelegateNode.__gc_function then
        self.m_Functions = setmetatable({},{__mode = "v"})
    else
        self.m_Functions = {}
    end
    self.m_CallCount = callcount or 0
    self.m_HasCallCount = 0
    self.m_FunctionCount = 0
    self.m_ID = g_DelegateMgr:GetID()
    self:Add(fun)

    local cls = getmetatable(self)
    cls.__add = DelegateNode.Add
    cls.__sub = DelegateNode.Remove
    cls.__call = DelegateNode.Call
end

function  DelegateNode:dctor()
    self.m_Functions = nil
end

function  DelegateNode:__cache()
    table.clear(self.m_Functions)
end

function DelegateNode:__reset(fun,callcount)
    self.m_CallCount = callcount or 0
    self.m_HasCallCount = 0
    self.m_FunctionCount = 0
    self.m_ID = g_DelegateMgr:GetID()
    self:Add(fun)
end

function DelegateNode:GetID()
    return self.m_ID
end

function DelegateNode:IsConsumed()
    if self.m_CallCount == 0 then
        return false
    end
    return self.m_HasCallCount >= self.m_CallCount
end

function DelegateNode:Add(fun)
    if table.index(self.m_Functions,fun) then
        return
    end
    table.insert(self.m_Functions,fun)
    self.m_FunctionCount = self.m_FunctionCount + 1
    return self
end

function  DelegateNode:Remove(fun)
    local index = table.index(self.m_Functions,fun)
    if index then
        table.remove(self.m_Functions,index)
        self.m_FunctionCount = self.m_FunctionCount - 1
    end
    return self
end

function  DelegateNode:Call(...)
    if self:IsConsumed() then
        return
    end
    self.m_HasCallCount = self.m_HasCallCount + 1
    for i = 1, self.m_FunctionCount do
        local fun = self.m_Functions[i]
        if fun then
            fun(...)
        end
    end
end

return DelegateNode