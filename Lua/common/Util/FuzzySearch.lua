--- FuzzySearch 功能说明
--- time:2023-05-19
--- author：zensyue
--- notes: 用于模糊搜索

---@class FuzzySearch
local FuzzySearch = Aclass("FuzzySearch")

function FuzzySearch:ctor()
	self.fuzzy_serarch_map = {}
end

function FuzzySearch:dctor()
	self.fuzzy_serarch_map = nil
end

local function getSearchCharList(str)
	local list = string.utf8list(str)
	local t = {}
	local len = #list
	local map = {}

	for i=1,len-1 do
		for j=len,i+1,-1 do
			local char = ""
			for k=i,j do
				char = char .. list[k]
			end
			if not map[char] then
				t[#t+1] = char
				map[char] = true
			end
		end
	end
	return t,list
end

local function getAllCharList(str)
	local search_list,list = getSearchCharList(str)
	table.insertlist(search_list, list)
	return search_list
end

--- 初始化模糊搜索配置表
---@param config table
---@param search_key string
function FuzzySearch:initConfig(config,search_key)
	if not config then
		return
	end
	for k,v in pairs(config) do
		local save_value = v
		local search_key_str = v[search_key]
		local search_key_char_list = getAllCharList(search_key_str)
		for _,char in pairs(search_key_char_list) do
			self.fuzzy_serarch_map[char] = self.fuzzy_serarch_map[char] or {}
			self.fuzzy_serarch_map[char][#self.fuzzy_serarch_map[char]+1] = save_value
		end
	end
end

--- 初始化模糊搜索字符串列表
---@param list string[]
function FuzzySearch:initStringList(list)
    for k,v in pairs(list) do
		local save_value = v
		local search_key_str = v
		local search_key_char_list = getAllCharList(search_key_str)
		for _,char in pairs(search_key_char_list) do
			self.fuzzy_serarch_map[char] = self.fuzzy_serarch_map[char] or {}
			self.fuzzy_serarch_map[char][#self.fuzzy_serarch_map[char]+1] = save_value
		end
	end
end

---@private
function FuzzySearch:getWeightList(find_char_list,use_count)
    local map = self.fuzzy_serarch_map
	use_count = use_count or 0
	local len = #find_char_list
	local weight_map = {}
	local index = 0
	for i=1,len do
		local char = find_char_list[i]
		if map[char] then
			local len = #map[char]
			for j=1,len do
				index = index + 1
				local save_value = map[char][j]
				if not weight_map[save_value] then
					weight_map[save_value] = {char_list = {char},save_value = save_value,index = index,use_count = 1}
				else
					weight_map[save_value].use_count = weight_map[save_value].use_count + 1
					weight_map[save_value].char_list[#weight_map[save_value].char_list+1] = char
				end
			end
		end
	end
    
	local t = {}
	for k,v in pairs(weight_map) do
		if v.use_count >= use_count then
			t[#t+1] = v
		end
	end

	local function sortFunc(a,b)
		if a.use_count == b.use_count then
			return a.index < b.index
		else
			return a.use_count > b.use_count
		end
	end
	table.sort(t,sortFunc)
	local value_list = {}
	local len = #t
	for i=1,len do
		value_list[#value_list+1] = t[i].save_value
	end
	return value_list
end

--- 模糊搜索
---@return table
function FuzzySearch:find(find_str)
	local search_list,list = getSearchCharList(find_str)
	local find_list = self:getWeightList(search_list)
	local find_list_2 = self:getWeightList(list,#list-1)

	local len = #find_list_2
	for i=1,len do
		local value = find_list_2[i]
		if not table.index(find_list,value) then
			find_list[#find_list+1] = value
		end
	end
	return find_list
end

return FuzzySearch
