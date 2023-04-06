--------------------------------------------------------------------------------
--      Copyright (c) 2022 , ZensYue ZensYue@163.com
--      All rights reserved.
--      Use, modification and distribution are subject to the "MIT License"
--------------------------------------------------------------------------------


--- 提供常用的 事件、定时器、闭包 
--- 订阅或者红点，应该再上层提供 绑定具体逻辑
--- 该类提供的方法 不要重写;开启 object.checkislegal=true 在New派生类的时候会检查是否重写


---@class object
local object = Aclass("object")

object.checkislegal = false

function object:ctor() 
    ---@type table<Event,number[]>   
    self.__m_events = nil

    ---@type table<string,number>
    self.__m_times = nil

    --- 闭包缓存
    ---@type table<string,fun()>
    self.__m_handlers = nil

    --- 闭包缓存 带一个参数
    ---@type table<string,table<any,fun()>>
    self.__m_handlers_p = nil

    --- 代理列表
    ---@type table<fun(),DelegateNode>
    self.__m_delegates = nil

    if object.checkislegal then
        self:isfunctionslegal()
    end
end

--- 模拟析构函数 需要清理事件、定时器、闭包、代理
function  object:dctor()
    self:ClearEvent()
    self:ClearTime()
    self:ClearDelegate()
    self:ClearHandler()
end

function  object:__reset()
end

--- 进入缓存池 需要清理事件、定时器、闭包、代理
function  object:__cache()
    self:ClearEvent()
    self:ClearTime()
    self:ClearDelegate()
    self:ClearHandler()
end

function object:ClearHandler()
    self.__m_handlers = nil
    self.__m_handlers_p = nil
end

--- 获取闭包函数 self.xxx 方法转为闭包函数 self.xxx(self,...)
---@param name string 方法名字
---@param param any 透传参数 尽量少用 可以为 nil。两个table,但内容相同 少用，没有判断table是否相同，会产生两个闭包
function object:handler(name,param)
    if param then
        if not self.__m_handlers_p then
            self.__m_handlers_p = {}
        end
        if not self.__m_handlers_p[name] then
            self.__m_handlers_p[name] = {}
        end
        if not self.__m_handlers_p[name][param] then
            self.__m_handlers_p[name][param] = handler_s(self,name,param)
        end
        return self.__m_handlers_p[name][param]
    else
        if not self.__m_handlers then
            self.__m_handlers = {}
        end
        if not self.__m_handlers[name] then
            self.__m_handlers[name] = handler_s(self,name)
        end
        return self.__m_handlers[name]
    end
end

--- 清理所有事件
function object:ClearEvent()
    if self.__m_events then
        for event, list in pairs(self.__m_events) do
            event:RemoveList(list)
        end
        self.__m_events = nil
    end
end

--- 添加Event 尽量不要重写
---@param key string 事件KEY
---@param funcname string
---@param param any 透传参数 尽量少用 可以为 nil
---@param event Event 不填，默认是 g_Event
function  object:AddEvent(key,funcname,param,event)
    if not self.__m_events then
        self.__m_events = {}
    end
    event = event or g_Event
    if not self.__m_events[event] then
        self.__m_events[event] = {}
    end
    local id = event:Add(key,self:handler(funcname,param))
    table.insert(self.__m_events[event],id)
    return id
end

--- 移除事件
---@param event_id number
---@param event Event 不填，默认是 g_Event
function object:RemoveEvent(event_id,event)
    if table.isempty(self.__m_events) then
        return
    end
    event = event or g_Event
    if table.isempty(self.__m_events[event]) then
        return
    end
    local index = table.index(self.__m_events[event],event_id)
    if index then
        table.remove(self.__m_events[event],index)
        event:Remove(event_id)
    end
end

--- 清理所有定时器
function object:ClearTime()
    if table.isempty(self.__m_times) then
        return
    end
    for handler, time_id in pairs(self.__m_times) do
        g_Timer:Stop(time_id)
    end
    self.__m_times = nil
end

--- 开启定时器，用handler返回的值做唯一值。
---@param isclear boolean 是否清理,如果清理会停掉已有;不清理，已有定时器不处理。填空默认是 true
---@param funcname string
---@param param any 透传参数 尽量少用 可以为 nil
---@param duration number 定时器间隔
---@param loop number 循环次数.小于0,无限循环.0,1次.大于0,n次.
---@param delay number 第一次循环的延迟时间.不填为 duration
---@param scale boolean 缩放值 默认是 true
---@return number 定时器唯一索引
function object:StartTime(isclear,funcname,param,duration,loop,delay,scale)
    if not self.__m_times then
        self.__m_times = {}
    end
    if isclear == nil then
        isclear = true
    end
    local handler = self:handler(funcname,param)
    if self.__m_times[handler] then
        if not isclear then
            return self.__m_times[handler]
        end
        self:StopTime(self.__m_times[handler])
    end
    self.__m_times[handler]  = g_Timer:Start(handler,duration,loop,delay,scale)
    return self.__m_times[handler]
end

---@param funcname string
---@param param any 透传参数 尽量少用 可以为 nil
---@param duration number 定时器间隔
---@param scale boolean 缩放值 默认是 true
---@return number 定时器唯一索引
function object:StartOnceTime(isclear,funcname,param,duration,scale)
    return self:StartTime(isclear,funcname,param,duration,1,duration,scale)
end

--- 停止定时器
function object:StopTime(time_id)
    g_Timer:Stop(time_id)
    if table.isempty(self.__m_times) then
        return
    end
    --- 定时器列表会很小 遍历代价不高
    local key = table.key(self.__m_times, time_id)
    if key then
        self.__m_times[key] = nil
    end
end


function object:ClearDelegate()
    if self.__m_delegates then
        for fn , delegate in pairs(self.__m_delegates) do
            g_DelegateMgr:Remove(delegate)
        end
        self.__m_delegates = nil
    end
end

---@param funcname string
---@param param any 透传参数 尽量少用 可以为 nil
---@param callcount number 执行次数
---@return DelegateNode
function object:CreateDelegate(funcname,param,callcount)
    if not self.__m_delegates then
        self.__m_delegates = {}
    end
    local handler = self:handler(funcname,param)
    local delegate
    if callcount then
        local id
        local function fn(...)
            handler(...)
            if self.__m_delegates then
                local delegate = self.__m_delegates[id]
                if delegate:IsConsumed() then
                    g_DelegateMgr:Remove(delegate)
                    self.__m_delegates[id] = nil
                end
            end
        end
        delegate = g_DelegateMgr:Create(fn,callcount)
        id = delegate:GetID()
        self.__m_delegates[id] = delegate
    else
        if self.__m_delegates[handler] then
            delegate = self.__m_delegates[handler]
        else
            delegate = g_DelegateMgr:Create(handler)
            self.__m_delegates[handler] = delegate
        end
    end
    return delegate
end

---@param delegate DelegateNode
function object:RemoveDelegate(delegate)
    if table.isempty(self.__m_delegates) then
        return
    end
    local k = table.index(self.__m_delegates,delegate)
    if k then
        g_DelegateMgr:Remove(delegate)
        self.__m_delegates[k] = nil
    end
end

--- 检查派生类是否重写了方法
function object:isfunctionslegal()
    if self.classtype == object then
        return
    end
    local check_list = {
        "ClearEvent",
        "AddEvent",
        "RemoveEvent",
        "ClearTime",
        "StartTime",
        "StartOnceTime",
        "StopTime",
        "ClearDelegate",
        "CreateDelegate",
        "RemoveDelegate",
    }

    for _, key in pairs(check_list) do
        if self[key] ~= object[key] then
            print(string.format("object:islegal the name is %s,function is %s,overrided warn!!!",self.classname,key))
        end
    end
end

return object
