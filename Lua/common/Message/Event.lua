--------------------------------------------------------------------------------
--      Copyright (c) 2022 , ZensYue ZensYue@163.com
--      All rights reserved.
--      Use, modification and distribution are subject to the "MIT License"
--------------------------------------------------------------------------------

--- 事件系统
--- 支持延迟触发事件，指定time时间内最多触发一次。可用于频发刷新的情况

---@class Event
local Event = Aclass("Event")

function Event:ctor()
    self.increment_id = 0
    
    self.event_count = 0
    self.events = {}
    self.events_map = {}

    self.lock_states = {}
    self.lock_add_list = {}
    self.lock_del_list = {}

    self.time_events = {}
end

--- notes: 新加监听事件
---@return number
function Event:Add(event, handler)
    if not event then
        error("event parameter in addlistener function has to be string, " .. type(event) .. " not right.event_name is "..event)
    end
    if not handler or type(handler) ~= "function" then
        error("handler parameter in addlistener function has to be function, " .. type(handler) .. " not right")
    end

    if not self.events[event] then
        self.events[event] = {ids = {},handlers = setmetatable({}, {__mode="v"})}
    end
    local events = self.events[event]
    
    self.event_count = self.event_count + 1
    self.increment_id = self.increment_id + 1
    local eventID = self.increment_id
    if self.lock_states[event] then
        self.lock_add_list[event] = self.lock_add_list[event] or {}
        local lock_add_list = self.lock_add_list[event]
        lock_add_list[#lock_add_list + 1] = { id = eventID, event = event, handler = handler }
        return eventID
    end
    table.insert(events.ids,eventID)
    table.insert(events.handlers,handler)
    self.events_map[eventID] = event
    return eventID
end

--- 触发事件
---@param event number|string
function Event:Brocast(event, ...)
    if table.isempty(self.events[event]) then
        return
    end
    if self:IsTimeEvent(event) then
        self:TimeBrocast(event,...)
    else
        self:Call(event, ...)
    end
end

--- 触发事件 外部不要调用
---@private
---@param event number|string
function Event:Call(event, ...)
    --- 同一时间只能执行一次
    if self.lock_states[event] then
        return
    end
    self.lock_states[event] = true
    local event_list = self.events[event]
    for i = 1, #event_list.ids do
        local event_id = event_list.ids[i]
        local handler = event_list.handlers[i]
        if not self.lock_del_list[event] or not self.lock_del_list[event][event_id] then
            handler(...)
        end
    end
    self.lock_states[event] = false
    self:CheckLockList(event)
end

--- 处理Call期间的 增删
---@private
function Event:CheckLockList(event)
    if not table.isempty(self.lock_add_list[event]) then
        local len = #self.lock_add_list[event]
        for i = 1, len do
            local event_info = self.lock_add_list[event][i]
            table.insert(self.events[event_info.event].ids,event_info.id)
            table.insert(self.events[event_info.event].handlers,event_info.handler)
            self.events_map[event_info.id] = event_info.event
        end

        self.lock_add_list[event] = nil
    end

    if not table.isempty(self.lock_del_list[event]) then
        for event_id, v in pairs(self.lock_del_list[event]) do
            self:Remove(event_id)
        end
        self.lock_del_list[event] = nil
    end
end

--- 移除单个事件
---@param event_id number
function Event:Remove(event_id)
    local event = self.events_map[event_id]
    if self.lock_states[event] then
        self.lock_del_list[event] = self.lock_del_list[event] or {}
        self.lock_del_list[event][event_id] = true
        return
    end
    self.events_map[event_id] = nil
    local events = self.events[event]
    if table.isempty(events) or table.isempty(events.ids) then
        return
    end
    --- 一定会成对出现
    local index = table.index(events.ids,event_id)
    if index then
        table.remove(events.ids,index)
        table.remove(events.handlers,index)
    end
end

--- notes: 移除事件列表
---@param tab number[]
function Event:RemoveList(tab)
    for k, v in pairs(tab) do
        self:Remove(v)
    end
end


function Event:IsTimeEvent(event)
    return self.time_events[event] ~= nil
end

--- 延迟事件
--- 事件多次触发 {time} 内只会触发一次。该事件callback不能透传参数，切记
---@param event string|number 事件Key
---@param time number 时间间隔
function Event:SetTimeInfo(event, time)

    if self.time_events[event] then
    	return
    end

    local info = {
        time_id = false,				--定时器ID
        interval = time,				--间隔时间
        count = 0,						--间隔时间内执行的数量 用于统计
        last_time = g_Timer:GetTime() - time,	--上一次调用的时间,初始化保证下一次能马上使用
    }
    self.time_events[event] = info
end

--- 内部调用，外部不要使用
---@private
function Event:TimeBrocast(event,...)
    --- 正常不为空
	local info = self.time_events[event]
	if not info then
		self:Call(event,...)
        return
	end
	if info.time_id then
		info.count = info.count + 1
    else
		local function func()
            self:Call(event)
            info.last_time = g_Timer:GetTime()
            info.count = 0
            info.time_id = false
            info.callback = false
        end
        info.time_id = g_Timer:StartOnce(func,info.interval)
	end
end

--- 移除所有事件
function Event:RemoveAll()
    self.event_count = 0
    self.events = {}
    self.events_map = {}
    if self.time_events then
        for event, info in pairs(self.time_events) do
            if info.time_id then
                g_Timer:Stop(info.time_id)
            end
        end
        self.time_events = nil
    end
end

return Event
