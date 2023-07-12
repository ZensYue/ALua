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
	---@type Tree
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
		node.data:SetDirty(false)
		
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
	-- return self.m_reddottree:findnode(nil,key)
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
	if (data.m_showtype == ReddotType.ShowType.DayOnce or data.m_showtype == ReddotType.ShowType.PlatformOnce) and data.m_showtime > 0 then
		--- 缓存到本地
		self:StartCacheTime(data)
	end
end

---*************************/////
--- notes: 本地缓存 start

--- 加载缓存文件
--- 要避免切号问题,所以需要外部调用.切号要用不同的文件路径加载.注意移动平台要传可读写路径
function ReddotTreeMgr:LoadCacheFile(filePath)
	if self.m_ReddotCaches then
		self:LogoutCheckCache()
	end
	self.m_CacheFilePath = filePath

	local cacheTab = {}

	local isexist = io.exists(self.m_CacheFilePath)
	if isexist then
		for content in io.lines(self.m_CacheFilePath) do
			local tab = string.split(content,",")
			local key = tab[1]
			local showType = tonumber(tab[2])
			local time
			if showType == ReddotType.ShowType.DayOnce then
				time = tonumber(tab[3])
			end
			cacheTab[key] = {
				key = key,
				showType = showType,
				time = time,
			}
		end
	end

	---@type ReddotCacheInfo[]
    self.m_ReddotCaches = cacheTab

	local curTime = os.time()
	local removeKeys
	for key, info in pairs(self.m_ReddotCaches) do
		local isCache = false
		if info.showType == ReddotType.ShowType.DayOnce then
			local diffDay = timeutil.getdiffday(curTime,info.time)
			if diffDay == 0 then
				isCache = true
			else
				removeKeys = removeKeys or {}
				removeKeys[#removeKeys+1] = key
			end
		elseif info.showType == ReddotType.ShowType.PlatformOnce then
			isCache = true
		end
		if isCache then
			self:SetNodeShowType(key,info.showType)
			local node = self:GetNodeOrCreate(key)
			node.data.m_showtime = 1
			node.data.m_value = 0
		end
	end

	if removeKeys then
		for _, key in pairs(removeKeys) do
			self.m_ReddotCaches[key] = nil
		end
	end
end

---@param data ReddotData
function ReddotTreeMgr:StartCacheTime(data)
	if not self.m_ReddotCaches then
		error("[error]未初始化红点数据")
		return
	end
	if self.m_ReddotCaches[data.m_key] then
		local info = self.m_ReddotCaches[data.m_key]
		info.key = data.m_key
		info.showType = data.m_showtype
		info.time = os.time()
	else
		self.m_ReddotCaches[data.m_key] = {
			key = data.m_key,
			showType = data.m_showtype,
			time = os.time()
		}
	end

	if self.time_id then
		return
	end
	local function step()
		self:SaveCacheFile()
		self.time_id = nil
	end
	local time = 3
	self.time_id = g_Timer:StartOnce(step, time)
end

--- 主动退出游戏 需要手动调用
--- 避免单日只显示一次,遇到跨天问题.
--- 比如第一天勾选单日只显示一次,跨天才退出游戏,第二天打开游戏是否勾选状态?需要的自行打开下面屏蔽代码
function ReddotTreeMgr:LogoutCheckCache()
	if not self.m_ReddotCaches then
		return
	end

	--- 自行开启
	-- for key, info in pairs(self.m_ReddotCaches) do
	-- 	if info.showType == ReddotType.ShowType.DayOnce then
	-- 		info.time = os.time()
	-- 	end
	-- end

	self:SaveCacheFile()
	if self.time_id then
		g_Timer:Stop(self.time_id)
		self.time_id = nil
	end
	self.m_ReddotCaches = nil
end

function ReddotTreeMgr:SaveCacheFile()
	if not self.m_CacheFilePath then
		return
	end
	local contents = {}
	for _, value in pairs(self.m_ReddotCaches) do
		if value.showType == ReddotType.ShowType.DayOnce then
			contents[#contents+1] = string.format("%s,%s,%s",value.key,value.showType,value.time)
		elseif value.showType == ReddotType.ShowType.PlatformOnce then
			contents[#contents+1] = string.format("%s,%s",value.key,value.showType)
		end
	end
	io.writefile(self.m_CacheFilePath,table.concat(contents,"\n"))
end
--- notes: 本地缓存 end
---*************************/////


return ReddotTreeMgr