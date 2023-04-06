--
-- @Author: ZensYue
-- @Date:   2021-08-31 10:40:50
--

--- 红点系统 红点实时性不要求不太强，内置延迟刷新 ReddotData.RefreshTime
---@class ReddotTreeMgr
local ReddotTreeMgr = Aclass("ReddotTreeMgr")

ReddotTreeMgr.KeySplitChar = "_"

ReddotTreeMgr.Debug = true

function ReddotTreeMgr:ctor()
	self.m_reddottree = Tree.New(nil,"top")

	--- 红点key保证唯一，这里取巧做个字典索引
	---@type table<string,TreeNode>
	self.m_reddotnodes = {}
	self:Reset()
end

--- 切换账号清掉这里即可
function ReddotTreeMgr:Reset()
	--- 清除节点数据即可，不用清除节点本身
	for _, node in pairs(self.m_reddotnodes) do
		if node.data then
			node.data:Clear()
		end
	end
end

--- 设置红点数据
---@param key string
---@param num number
function ReddotTreeMgr:SetNodeNum(key,num)
	if ReddotTreeMgr.Debug then
		assert(type(num) == "number",tostring(num) .. " 必须是数字")
	end
	local node = self:GetNodeOrCreate(key)
	if node.child_list and #node.child_list > 0 then
		if ReddotTreeMgr.Debug then
			assert(false,key .. " 中间节点不能直接改数值")
		end
	end
	node.data:SetValue(num)
	if node.data:IsParentDirty() then
		self:SetParentValue(node)
		
		-- local cur_node = node
		-- while(cur_node and cur_node.data)do
		-- 	cur_node.data:SetDirty(false)
		-- 	cur_node = cur_node.parent_node
		-- end
	end
end

--- 获取红点节点数据
function ReddotTreeMgr:GetNodeValue(key)
	local node = self:FindNode(key)
	if not node or not node.data then
		return 0
	end
	return node.data:GetValue()
end

--- 获取红点节点数据
function ReddotTreeMgr:GetNodeShowState(key)
	local node = self:FindNode(key)
	if not node or not node.data then
		return false
	end
	return node.data:GetShowState()
end
 
--- 刷新父节点数据
---@private
function ReddotTreeMgr:SetParentValue(node)
	node = node.parent_node
	if not node or not node.data then
		return
	end
	local len = #node.child_list
	local value = 0
	for i=1,len do
		local child_node = node.child_list[i]
		---@type ReddotData
		local data = child_node.data
		local child_value = data:GetShowValue()
		value = value + child_value
	end
	node.data:SetValue(value)
	self:SetParentValue(node)
end

--- 设置红点显示类型 1 普通;2 当次登录只显示一次; 3 当日只显示一次;
function ReddotTreeMgr:SetNodeShowType(key,showtype)
	---@type TreeNode
	local node = self:GetNodeOrCreate(key)
	---@type ReddotData
	local data = node.data
	data:SetShowType(showtype)
end

--- 设置红点数据类型 1 bool;2 number
function ReddotTreeMgr:SetNodeType(key,type)
	local node = self:GetNodeOrCreate(key)
	---@type ReddotData
	local data = node.data
	data:SetType(type)
end

function ReddotTreeMgr:GetNode(key)
	return self:FindNode(key)
end

function ReddotTreeMgr:GetNodeOrCreate(key)
	local node = self:FindNode(key)
	if not node then
		node = self:CreateNode(key)
	end
	return node
end

---@private
function ReddotTreeMgr:CreateNode(key)
	local parent_node = nil
	local start_idnex,_ = string.find(key,ReddotTreeMgr.KeySplitChar)
	if start_idnex then
		local ss = string.split(key,ReddotTreeMgr.KeySplitChar)
		local parent_key = table.concat( ss, ReddotTreeMgr.KeySplitChar, 1, #ss-1)
		local _node = self:FindNode(parent_key)
		if not _node then
			_node = self:CreateNode(parent_key)
		end
		parent_node = _node
	end
	local data = ReddotData.New(key)
	local node =  self.m_reddottree:addnode(parent_node,key,data)
	self.m_reddotnodes[key] = node
	return node
end

---@private
function ReddotTreeMgr:FindNode(key)
	local node = self.m_reddotnodes[key]
	if node then
		return node
	end
	return self.m_reddottree:findnode(nil,key)
end

---@private
function ReddotTreeMgr:OnChangeReddot(key,value)
	--- 派发红点刷新事件
	g_Event:Brocast("UpdateReddot",key,value)

	local node = self.m_reddotnodes[key]
	if not node then
		return
	end
	---@type ReddotData
	local data = node.data
	if data.m_showtype == ReddotType.ShowType.DayOnce then
		--- 缓存到本地
		self:SaveDayShowCache(key,value)
	end
end

---*************************/////
--- notes: 本地缓存 未处理 start
---@param key string
---@param value number|boolean
function ReddotTreeMgr:SaveDayShowCache(key,value)
	-- Todo

end

function ReddotTreeMgr:InitDayShowCache()
end
--- notes: 本地缓存 end
---*************************/////


return ReddotTreeMgr