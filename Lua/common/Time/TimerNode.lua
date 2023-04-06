--------------------------------------------------------------------------------
--      Copyright (c) 2022 , ZensYue ZensYue@163.com
--      All rights reserved.
--      Use, modification and distribution are subject to the "MIT License"
--------------------------------------------------------------------------------


---@class TimerNode
local TimerNode = Aclass("TimerNode")

--- 缓存100个
TimerNode.__cache_count = 100
classcacheagent(TimerNode)

function TimerNode:ctor()
    self.m_IsFinish = false
end

function TimerNode:dctor()
    self.m_Callback = nil
    self.m_Timer = nil
end

function TimerNode:__cache()
    self.m_Callback = nil
    self.m_Timer = nil
end

function TimerNode:__reset()
    self.m_IsFinish = false
end

function TimerNode:SetData(id,f,duration,loop,delay,scale)
    self.m_ID = id
    self.m_Callback = f
    self.m_Duration = duration
    self.m_Loop = loop
    self.m_DelayTime = delay or duration
    self.m_Scale = scale
end

function TimerNode:SetTimer(timer)
    ---@type Timer
    self.m_Timer = timer
end

function TimerNode:SetDebug(bo)
    self.m_Debug = bo
end

function TimerNode:Update(deltaTime,realDeltaTime)
    if self.m_IsFinish then
        return
    end
    local delta
    if self.m_Scale then
        delta = realDeltaTime or deltaTime
    else
        delta = deltaTime
    end
    self.m_DelayTime = self.m_DelayTime - delta
    if self.m_DelayTime <= 0 then
        local status, err = pcall(self.m_Callback,delta)
        --- pcall 失败，输出错误信息
        if not status then
            --- 调试状态 输出发起定时器的堆栈
            if self.m_Debug then
                self:print(self.source,err)
            else
                self:print(err)
            end
            -- 调试状态再调用一次，放大错误
            if self.m_Debug then
                self.m_Callback(delta)
            end
        end

        if self.m_IsFinish then
            return
        end

        if self.m_Loop > 0 then
            self.m_Loop = self.m_Loop - 1
            self.m_DelayTime = self.m_DelayTime + self.m_Duration
        end
        
        if self.m_Loop == 0 then
            self.m_IsFinish = true
        elseif self.m_Loop < 0 then
            self.m_DelayTime = self.m_DelayTime + self.m_Duration
        end
    end		
end

function TimerNode:print(...)
    if self.m_Timer then
        self.m_Timer:print(...)
    end
end

return TimerNode
