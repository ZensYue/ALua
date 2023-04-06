--------------------------------------------------------------------------------
--      Copyright (c) 2022 , ZensYue ZensYue@163.com
--      All rights reserved.
--      Use, modification and distribution are subject to the "MIT License"
--------------------------------------------------------------------------------

--- 订阅系统
---@class SubscribeMgr
local SubscribeMgr = Aclass("SubscribeMgr")

function SubscribeMgr:ctor()
    --- 具体的节点逻辑
    ---@type SubscribeNode[]
    self.m_Nodes = {}

    --- 订阅组
    ---@type SubscribeGroup[]
    self.m_Groups = {}

    --- 节点类型id映射
    ---@type string[]
    self.m_NodesIdTypeMap = {}

    --- 保存数据
    ---@type string[]
    self.m_Values = {}


    self.increment_id = 0
end

--- 获取值
---@private
---@return number
function SubscribeMgr:GetValue(key)
    return self.m_Values[key] or 0
end

--- 获取节点
---@private
---@return SubscribeNode
function SubscribeMgr:GetNode(id)
    return self.m_Nodes[id] or 0
end

---*************************/////
--- notes: 外部接口 start

--- 清除数据
--- 切换账号时调用
function SubscribeMgr:Reset()
    for _, node in pairs(self.m_Nodes) do
        node:Delete()
    end
    self.m_Nodes = {}
    
    for _, group in pairs(self.m_Groups) do
        group:Delete()
    end
    self.m_Groups = {}

    self.m_Values = {}

    self.m_NodesIdTypeMap = {}
end

--- 创建节点
---@param key string
---@param value number
---@param callback fn<SubscribeNode,boolean>
---@param type number See SubscribeType
---@param isUpdateValue boolean 是否刷新数据，不填默认是刷新
---@return SubscribeNode
function SubscribeMgr:CreateNode(key,value,callback,type,isUpdateValue)
    isUpdateValue = isUpdateValue == nil and true or isUpdateValue
    self.increment_id = self.increment_id + 1
    local node = SubscribeNode.New(key,value,callback,type)

    node:SetID(self.increment_id)
    self.m_Nodes[self.increment_id] = node
    if not self.m_NodesIdTypeMap[key] then
        self.m_NodesIdTypeMap[key] = {}
    end
    table.insert(self.m_NodesIdTypeMap[key],node.m_Id)
    if isUpdateValue then
        node:UpdateValue()
    end
    return node
end

--- Remove节点
---@param node SubscribeNode
function SubscribeMgr:RemoveNode(node)
    local key = node.m_Key
    if not table.isempty(self.m_NodesIdTypeMap[key]) then
        local index = table.index(self.m_NodesIdTypeMap[key],node.m_Id)
        if index then
            table.remove(self.m_NodesIdTypeMap[key],index)
        end
    end
    self.m_Nodes[node.m_Id] = nil

    if node.m_GroupID then
        local groupNode = self.m_Groups[node.m_GroupID]
        if groupNode then
            groupNode:RemoveNode(node)
        end
    end

    node:Delete()
end

--- 刷新数据 需要各系统主动调用
---@param key string
---@param value number
function SubscribeMgr:UpdateValue(key,value)
    if self.m_Values[key] == value then
        return
    end
    self.m_Values[key] = value
    if not table.isempty(self.m_NodesIdTypeMap[key]) then
        for i = 1, #self.m_NodesIdTypeMap[key] do
            local id = self.m_NodesIdTypeMap[key][i]
            local node = self:GetNode(id)
            if node then
                node:UpdateValue()
            end
        end
    end
end

--- 创建组合节点
---@param callback fn<SubscribeNode,boolean>
---@param type number See SubscribeType
---@return SubscribeGroup
function SubscribeMgr:CreateGroup(callback,type)
    self.increment_id = self.increment_id + 1
    local group = SubscribeGroup.New(callback,type)
    group:SetID(self.increment_id)
    self.m_Groups[self.increment_id] = group
    return group
end

--- 向 SubscribeGroup 添加一个 SubscribeNode
---@param groupNode SubscribeGroup
---@return SubscribeNode
function SubscribeMgr:AddGroupNode(groupNode,key,value,type)
    if not groupNode then
        return
    end
    -- assert(groupNode:GetNode(key) == nil,"同组不能拥有两个相同KEY的NODE")
    local node = self:CreateNode(key,value,groupNode.m_node_callback,type,false)
    groupNode:AddNode(node)
    node.m_GroupID = groupNode.m_ID
    return node
end

--- 向 SubscribeGroup 添加一个 SubscribeGroup ,group(A&group(B|C))
---@param groupNode SubscribeGroup
---@param type number See SubscribeType
---@return SubscribeGroup
function SubscribeMgr:AddGroup(groupNode,type)
    self.increment_id = self.increment_id + 1
    local group = SubscribeGroup.New(groupNode.m_node_callback,type)
    group:SetID(self.increment_id)
    self.m_Groups[self.increment_id] = group
    groupNode:AddNode(group)
    return group
end

--- 移除组合节点
--- 不用的时候需要主动删除
function SubscribeMgr:RemoveGroup(groupNode)
    if not groupNode then
        return
    end
    self.m_Groups[groupNode.m_ID] = nil
    if groupNode.Delete then
        groupNode:Delete()
    end
end

--- notes: 外部接口 end
---*************************/////

return SubscribeMgr
