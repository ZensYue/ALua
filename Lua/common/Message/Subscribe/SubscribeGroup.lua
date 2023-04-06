--------------------------------------------------------------------------------
--      Copyright (c) 2022 , ZensYue ZensYue@163.com
--      All rights reserved.
--      Use, modification and distribution are subject to the "MIT License"
--------------------------------------------------------------------------------

--- 订阅组 支持多个Key。支持and 或 or
---@class SubscribeGroup
local SubscribeGroup = Aclass("SubscribeGroup")

--- 构造函数 顺序 基类到派生类
function SubscribeGroup:ctor(callback,type)
    self.m_Callback = callback
    self.m_Type = type or SubscribeType.GROUP_AND

    self.m_Finish = nil
    ---@type SubscribeNode
    self.m_Nodes = {}

    self.m_node_callback = function(node,bo)
        self:NodeCallBack(node,bo)
    end

    self:Init()
end

--- 析构函数 顺序 派生类到基类
function SubscribeGroup:dctor()
    for _, node in pairs(self.m_Nodes) do
        if node.classname == self.classname then
            g_SubscribeMgr:RemoveGroup(node)
        else
            g_SubscribeMgr:RemoveNode(node)
        end
    end
end

---@private
function SubscribeGroup:SetID(id)
    self.m_ID = id
end

---@private
function SubscribeGroup:Init()
end

function SubscribeGroup:Contain(node)
    return table.index(self.m_Nodes,node) ~= node
end

---@private
---@param node SubscribeNode
---@param bo boolean
function SubscribeGroup:NodeCallBack(node,bo)
    local index = table.index(self.m_Nodes,node)
    if index then
        self:UpdateValue()
    end
end

function SubscribeGroup:AddNode(node)
    local index = table.index(self.m_Nodes,node)
    if not index then
        table.insert(self.m_Nodes,node)
    end
end

--- 主动移除Node
---@param node SubscribeNode
function SubscribeGroup:RemoveNode(node)
    local index = table.index(self.m_Nodes,node)
    if index then
        table.remove(self.m_Nodes,index)
    end
end


---*************************/////
--- notes: 外部接口 start

function SubscribeGroup:ResetTarget()
    for _, node in pairs(self.m_Nodes) do
        node:ResetTarget()
    end
    
end

function SubscribeGroup:GetNode(key)
    return table.getattributevalue(self.m_Nodes,"m_Key",key)
end

function SubscribeGroup:UpdateValue()
    local bo = self:IsFinish()
    if bo == self.m_Finish then
        return
    end
    self.m_Finish = bo
    if self.m_Callback then
        self.m_Callback(self,bo)
    end
end

function SubscribeGroup:IsFinish()
    if self.m_Type == SubscribeType.GROUP_AND then
        for _, node in pairs(self.m_Nodes) do
            if not node:IsFinish() then
                return false
            end
        end
        return true
    elseif self.m_Type == SubscribeType.GROUP_OR then
        for _, node in pairs(self.m_Nodes) do
            if node:IsFinish() then
                return true
            end
        end
        return false
    end
end

--- notes: 外部接口 end
---*************************/////


return SubscribeGroup
