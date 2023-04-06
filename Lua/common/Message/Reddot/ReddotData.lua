--
-- @Author: ZensYue
-- 红点数据


---@class ReddotData
local ReddotData = Aclass("ReddotData")

--- 数据变更红点刷新的延迟时间
ReddotData.RefreshTime = 1.0

function ReddotData:ctor(key,showtype,type)
	self.m_key = key
	self.m_showtype = showtype or ReddotType.ShowType.Normal
	self.m_type = type or ReddotType.ValueType.Bool

	self.m_value = 0
	self.m_showtime = 0
	self.m_dirty = false
	if self.m_type == ReddotType.ValueType.Bool then
		self.m_dirty_value = {old=false,new=false}
	else
		self.m_dirty_value = {old=0,new=0}
	end
end

function ReddotData:Clear()
	self.m_value = 0
	self.m_showtime = 0
	self.m_dirty = false
	if self.m_type == ReddotType.ValueType.Bool then
		self.m_dirty_value = {old=false,new=false}
	else
		self.m_dirty_value = {old=0,new=0}
	end
	self:StopTime()
end

function ReddotData:SetValue(num)
	local old_v = self.m_value
	self.m_value = num

	if old_v ~= num then
		if old_v > 0 and self.m_value == 0 then
			self.m_showtime = self.m_showtime + 1
			if self.m_showtime == 1 then
				self:SetDirtyValue(num)
				return
			end
		end
		if (self.m_showtype == ReddotType.ShowType.LoginOnce
			or self.m_showtype == ReddotType.ShowType.DayOnce) and self.m_showtime > 0 then
			return
		else
			self:SetDirtyValue(num)
		end
	end
end

function ReddotData:IsDirty()
	return self.m_dirty
end

function ReddotData:SetDirtyValue(num)
	local value = self:ConvertValue(num)
	if self.m_dirty_value.old == value then
		self:StopTime()
		self:SetDirty(false)
		return
	end
	if self.m_dirty_value.new == value then
		return
	end
	self.m_dirty_value.new = value
	if not self.time_id then
		self:StartTime()
	end
end

function ReddotData:StartTime()
	self:StopTime()
	self:SetDirty(true)
	local function step()
		self:StopTime()
		self:SetDirty(false)
		-- todo
		self.m_dirty_value.old = self.m_dirty_value.new
		g_ReddotTreeMgr:OnChangeReddot(self.m_key,self.m_dirty_value.old)
	end
	 self.time_id = g_Timer:StartOnce(step,ReddotData.RefreshTime)
end

function ReddotData:StopTime()
	if self.time_id then
		g_Timer:Stop(self.time_id)
		self.time_id = nil
	end
end

function ReddotData:ConvertValue(value)
	if self.m_type == ReddotType.ValueType.Bool then
		return value > 0
	else
		return value
	end
end


--===============================
-- 外部接口
--*******************************
function ReddotData:SetShowType(showtype)
	self.m_showtype = showtype	
end

function ReddotData:SetType(type)
	self.m_type = type
	if self.m_type == ReddotType.ValueType.Bool then
		if _G.type(self.m_dirty_value.old) ~= "boolean" then
			self.m_dirty_value.old = self:ConvertValue(self.m_dirty_value.old)
		end
	else
		if _G.type(self.m_dirty_value.old) ~= "number" then
			self.m_dirty_value.old = self.m_dirty_value.old and 1 or 0
		end
	end
end

function ReddotData:GetValue()
	return self.m_value
end

function ReddotData:GetShowState()
	return self:GetShowValue() > 0
end

function ReddotData:GetShowValue()
	local value = 0
	if (self.m_showtype == ReddotType.ShowType.LoginOnce 
		or self.m_showtype == ReddotType.ShowType.DayOnce) and self.m_showtime > 0 then
		value = 0
	else
		value = self:GetValue()
	end
	return value
end

function ReddotData:SetDirty(dirty)
	self.m_dirty = dirty
end

function ReddotData:IsDirty()
	return self.m_dirty
end

--- 只有检查父节点是否有变化才需要用到
function ReddotData:IsParentDirty()
	return self:IsDirty() or self.m_dirty_value.old ~= self.m_dirty_value.new
end
--*******************************
-- 外部接口
--===============================

return ReddotData