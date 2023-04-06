--------------------------------------------------------------------------------
--      Copyright (c) 2022 , ZensYue ZensYue@163.com
--      All rights reserved.
--      Use, modification and distribution are subject to the "MIT License"
--------------------------------------------------------------------------------

--- class 对应的缓存机制
--- 调用 classcacheagent(cls)以及__cache_count 大于0 开启缓存机制
--- 需要重写 __cache(进入缓存池)和 __reset(缓存池取出) 两个方法，其中 __reset的函数参数和ctor一致
--- 注意:进入缓冲池,要把有可能影响其他模块GC的值要去除引用,比如 闭包,unity gameObject等

---@class classcacheagent
local classcacheagent = {}
classcacheagent.__index = classcacheagent

function classcacheagent.New()
	local t = setmetatable({}, {__index = classcacheagent,__call = classcacheagent.init_class})
	t:ctor()
	return t
end

function classcacheagent:ctor()
	self.m_class_list = {}
	self.m_class_count 	= 0
	self.m_object_count 	= 0
end

--- notes: 接管 class 的New和Delete.已设置__call,外部用classcacheagent() 会调用该方法
---@param cls table class() 返回的table
function classcacheagent:init_class(cls)
	if not self:islegal(cls) then
		return
	end
	cls.__New  = cls.New
	cls.New = function(...)
		local obj = self:pop(cls)
		if obj then
			if obj.__reset then
				obj:__reset(...)
			end
			return obj
		end
        return cls.__New(...)
    end
	cls.__Delete = cls.Delete
	cls.Delete = function(obj)
		--- 如果缓存失败，需要删除
		if self:push(obj) then
			if obj.__cache then
				obj:__cache()
			end
		else
			cls.__Delete(obj)
		end
	end
end

function classcacheagent:islegal(cls)
	local __cache_count = rawget(cls,"__cache_count")
	if not __cache_count or __cache_count == 0 then
		return false
	end
	return true
end

function classcacheagent:pop(cls)
	if table.isempty(self.m_class_list[cls.classname]) then
		return nil
	end
	local obj = table.remove(self.m_class_list[cls.classname])
	obj.__is_cache = false
	if table.isempty(self.m_class_list[cls.classname]) then
		self.m_class_count = self.m_class_count - 1
	end
	self.m_object_count = self.m_object_count - 1
	return obj
end

function classcacheagent:push(obj)
	local cls = obj.classtype
	if not self:islegal(cls) then
		return false
	end
	self.m_class_list[cls.classname] = self.m_class_list[cls.classname] or {}
	local list = self.m_class_list[cls.classname]
	local __cache_count = rawget(cls,"__cache_count")
	if #list >= __cache_count then
		return false
	end
	if table.isempty(list) then
		self.m_class_count = self.m_class_count + 1
	end
	table.insert(list,obj)
	self.m_object_count = self.m_object_count + 1
	obj.__is_cache = true
	return true
end

function classcacheagent:clear(cls)
	if table.isempty(self.m_class_list[cls.classname]) then
		return
	end
	for _, obj in pairs(self.m_class_list[cls.classname]) do
		cls.__Delete(obj)
	end
	self.m_class_list[cls.classname] = nil
end

return classcacheagent