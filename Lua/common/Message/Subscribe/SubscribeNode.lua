--------------------------------------------------------------------------------
--      Copyright (c) 2022 , ZensYue ZensYue@163.com
--      All rights reserved.
--      Use, modification and distribution are subject to the "MIT License"
--------------------------------------------------------------------------------

--- 订阅节点，游戏具体逻辑需要继承扩展功能。

-- lua 5.1
-- local bit = require "bit"

---@class SubscribeNode
local SubscribeNode = Aclass("SubscribeNode")
SubscribeNode.__cache_count = 100
classcacheagent(SubscribeNode)

function SubscribeNode:ctor(key,value,callback,type)
    self.m_Key = key
    self.m_TargetValue = value
    self.m_Callback = callback
    self.m_Type = type or SubscribeType.NORMAL
    self.m_Finish = nil
    self.m_Cache = false

    -- lua 5.1
    -- self.m_Reversal = bit.band(self.m_Type, SubscribeType.LessThan) ~= SubscribeType.LessThan 
    --- false:大于等于 true 小于等于
    self.m_Reversal = self.m_Type & SubscribeType.LessThan == SubscribeType.LessThan

    self:Init()
end

function SubscribeNode:dctor()
end

function SubscribeNode:__reset(key,value,callback,type)
    self:ctor(key,value,callback,type)
end

function SubscribeNode:__cache()
    self.m_Callback = nil
end

--- 外部不要调用,只能在 g_SubscribeMgr 主动调用
function SubscribeNode:SetID(id)
    self.m_Id = id
end

--- 外部不要调用,只能在 g_SubscribeMgr 主动调用
function SubscribeNode:UpdateValue()
    local bo = self:IsFinish()
    if bo == self.m_Finish then
        return
    end
    self.m_Finish = bo
    if self.m_Callback then
        self.m_Callback(self,bo)
    end
end

function SubscribeNode:Init()
    if self.m_Type == SubscribeType.INCREMENT then
        assert(self.m_TargetValue ~= 0,"增量订阅的目标值不能为0")
    end
    -- lua 5.1
    -- if bit.band(self.m_Type, SubscribeType.INCREMENT) == SubscribeType.INCREMENT then
    if self.m_Type & SubscribeType.INCREMENT == SubscribeType.INCREMENT then
        self.m_StartValue = g_SubscribeMgr:GetValue(self.m_Key)
    else
        self.m_StartValue = 0
    end
end

--- 重新设置目标值
---@param value number 重新设置起始值 nil和之前一样
---@param reset boolean 是否重新开始统计
function SubscribeNode:ResetTarget(value,reset)
    if value then
        self.m_TargetValue = value
    end
    if reset then
        self:Init()
    end
    self:UpdateValue()
end

function SubscribeNode:GetValue()
    return g_SubscribeMgr:GetValue(self.m_Key) - self.m_StartValue
end

function SubscribeNode:IsFinish()
    if self.m_Type == SubscribeType.Equal then
        return self:GetValue() == self.m_TargetValue
    elseif self.m_Reversal then
        return self:GetValue() <= self.m_TargetValue
    else
        return self:GetValue() >= self.m_TargetValue
    end
end
return SubscribeNode
