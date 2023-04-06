--------------------------------------------------------------------------------
--      Copyright (c) 2023 , ZensYue ZensYue@163.com
--      All rights reserved.
--      Use, modification and distribution are subject to the "MIT License"
--------------------------------------------------------------------------------

--- 模拟C#的委托
--- 用于(csharp|C|C++)与lua的闭包交互,只需要传一个id(number)即可.

---@class DelegateMgr
local DelegateMgr = Aclass("DelegateMgr")

function DelegateMgr:ctor()
    ---@type DelegateNode[]
    self.m_DelegateList = setmetatable({},{__mode = "v"})
    self.m_ID = 0
end

function DelegateMgr:dctor()
end

function DelegateMgr:GetID()
    self.m_ID = self.m_ID + 1
    return self.m_ID
end

---@return DelegateNode
function DelegateMgr:Create(func,callcount)
    local delegate = DelegateNode.New(func,callcount)
    self:Add(delegate)
    return delegate
end

---@param delegate DelegateNode
function DelegateMgr:Add(delegate)
    self.m_DelegateList[delegate:GetID()] = delegate
end

---@param delegate DelegateNode
function DelegateMgr:Remove(delegate)
    self.m_DelegateList[delegate:GetID()] = nil
    delegate:Delete()
end

function DelegateMgr:Call(id,...)
    local delegate = self.m_DelegateList[id]
    if delegate then
        delegate:Call(...)
        if delegate:IsConsumed() then
            self:Remove(delegate)
        end
    end
end

return DelegateMgr