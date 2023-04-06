--------------------------------------------------------------------------------
--      Copyright (c) 2022 , ZensYue ZensYue@163.com
--      All rights reserved.
--      Use, modification and distribution are subject to the "MIT License"
--------------------------------------------------------------------------------

local TimerNode = require "common.Time.TimerNode"

---定时器
---@class Timer
local Timer =  Aclass("Timer")
function Timer:ctor()
    self.m_ID = 0
	---@type TimerNode[]
	self.m_TimeList = {}
	self.m_TimeCount = 0

    self.m_Time = 0
    self.m_RealTime = 0
	self.m_FrameLoop = 0

	---@private
	self.m_IsUpdate = false

	---@type TimerNode[]
	self.m_WaitAddList = {}
     
    self.m_Debug = false
end

function Timer:dctor()
end

function Timer:update(time,realTime)
    if self.m_Time == 0 then
        self.m_Time = time
		self.m_RealTime = realTime or time
		return
    end
    local deltaTime = time - self.m_Time
    self.m_Time = time
    local realDeltaTime = realTime - self.m_RealTime
    self.m_RealTime = realTime
	if deltaTime == 0 and realDeltaTime == 0 then
		return
	end
	self.m_FrameLoop = self.m_FrameLoop + 1
	self.m_IsUpdate = true
	local delete_list

	for id,node in pairs(self.m_TimeList) do
		node:Update(deltaTime,realDeltaTime)
		if node.m_IsFinish then
			delete_list = delete_list or {}
			delete_list[#delete_list+1] = id
		end
	end

	self.m_IsUpdate = false
	
	if delete_list then
		for _,id in pairs(delete_list) do
			self:Stop(id)
		end
	end

    if not table.isempty(self.m_WaitAddList) then
        for id,node in pairs(self.m_WaitAddList) do
            self.m_TimeList[id] = node
        end
        table.clear(self.m_WaitAddList)
    end
end

---@param f fun(deltaTime:number)
---@param duration number 定时器间隔
---@param loop number 循环次数.小于0,无限循环.0,1次.大于0,n次.
---@param delay number 第一次循环的延迟时间.不填为 duration
---@param scale boolean 缩放值 默认是 true
---@return number 定时器唯一索引
function Timer:Start(f,duration,loop,delay,scale)
	duration = duration or 0
	loop = loop or 0
	delay = delay or duration
	scale = scale == nil and true or scale
	self.m_ID = self.m_ID + 1
	
	---@type TimerNode
	local node = TimerNode.New()
	node:SetTimer(self)
	node:SetDebug(self.m_Debug)
	node:SetData(self.m_ID,f,duration,loop,delay,scale)
	--- 调试状态，记录堆栈
	if self.m_Debug then
		node.source = debug.traceback()
	end

	if self.m_IsUpdate then
		self.m_WaitAddList[self.m_ID] = node
	else
		self.m_TimeList[self.m_ID] = node
	end
	self.m_TimeCount = self.m_TimeCount + 1
	return self.m_ID
end

---@param func fun(deltaTime:number)
---@param duration number 定时器间隔
---@param scale boolean 缩放值 默认是 true
---@return number 定时器唯一索引
function Timer:StartOnce(func,duration,scale)
	return self:Start(func,duration,1,duration,scale)
end

---@param func fun(deltaTime:number)
---@param frame number 帧数间隔 执行一次Update算 1 帧
---@param loop number 循环次数.小于0,无限循环.0,1次.大于0,n次.
---@param scale boolean 缩放值 默认是 true
---@return number 定时器唯一索引
function Timer:StartFrame(func,frame,loop,scale)
	loop = loop or 1
	local n=0
	local d=0
	local function f(delta)
		n = n + 1
		d = d + delta
		if n>=frame then
			func(d)
			n = 0
			d = 0
		end
	end
	if loop >= 1 then
		return self:Start(f,0,loop*frame,0,scale)
	else
		return self:Start(f,0,-1,0,scale)
	end
end

--- 停止定时器
---@param id number 定时器唯一索引
function Timer:Stop(id)
	--- 先删除等待列表
	if self.m_WaitAddList[id] then
		self.m_WaitAddList[id]:Delete()
		self.m_WaitAddList[id] = nil
		self.m_TimeCount = self.m_TimeCount - 1
		return
	end
	if not self.m_TimeList[id] then
		return
	end
	local node = self.m_TimeList[id]
	--- 如果在轮询中，m_IsFinish 标记为 true
	if self.m_IsUpdate then
		node.m_IsFinish = true
		return
	end
	self.m_TimeCount = self.m_TimeCount - 1
	node:Delete()
	self.m_TimeList[id] = nil
end

--- 定时器是否完成
function Timer:IsFinish(id)
	return self.m_WaitAddList[id] == nil and (not self.m_TimeList[id] or self.m_TimeList[id].m_IsFinish)
end

--- 获取定时器时间 可缩放
function Timer:GetTime()
	return self.m_Time
end

--- 获取定时器时间 真实时间
function Timer:GetRealTime()
	return self.m_RealTime
end

--- 获取定时器帧数
function Timer:GetFrame()
	return self.m_FrameLoop
end

--- 日志输出方法，外部注入
function Timer:SetPrint(fn)
    self.m_DebugFunc = fn
end

---@private
function Timer:print(...)
    if self.m_DebugFunc then
        self.m_DebugFunc(...)
    end
end

return Timer