--------------------------------------------------------------------------------
--      Copyright (c) 2023 , ZensYue ZensYue@163.com
--      All rights reserved.
--      Use, modification and distribution are subject to the "MIT License"
--------------------------------------------------------------------------------

--- 树结构 节点
---@class TreeNode
local TreeNode = Aclass("TreeNode")

TreeNode.treetype = {
	list = 0,		-- 有序
	map = 1,		-- 无序
}

function TreeNode:ctor(parent_node,key)
	self.child_list = nil
	self.parent_node = parent_node
	self.key = key
	self.seq = parent_node and parent_node.seq + 1 or 1
	self:settreetype(TreeNode.islist(key) and TreeNode.treetype.list or TreeNode.treetype.map)
end

function TreeNode:clear()
	self.child_list = nil
end

function TreeNode:setdata(data)
	self.data = data
end

function TreeNode:settreetype(tree_type)
	self.tree_type = tree_type
end

function TreeNode.islist(key)
	return not key or type(key) == "number"
end

function TreeNode:addchild(node)
	self.child_list = self.child_list or {}
	table.insert(self.child_list,node)
	node.index = #self.child_list
	if not node.key then
		node.key = node.index
	end
end

function TreeNode:removechilde(node)
	if not self.child_list then
		return
	end
	self.child_list = self.child_list or {}
	table.remove(self.child_list,node.index)
	for k,node in pairs(self.child_list) do
		node.index = k
	end
end

function TreeNode:equals(seq,key)
	if (not seq or seq == self.seq) and self.key == key then
		return true
	end
	return false
end

function TreeNode:findchild(seq,key)
	if seq and self.seq > seq then
		return nil
	end

	if self:equals(seq,key) then
		return self
	end
	
	if not self.child_list then
		return nil
	end

	local len = #self.child_list
	for i=1,len do
		local node = self.child_list[i]
		if node:equals(seq,key) then
			return node
		end
		local child = node:findchild(seq,key)
		if child then
			return child
		end
	end
	return nil
end

function TreeNode:walk(fn,id_depth)
	if id_depth == nil then
		id_depth = true
	end
	fn(self)
	if not id_depth then
		return
	end
	if not self.child_list then
		return
	end
	local len = #self.child_list
	for i=1,len do
		local node = self.child_list[i]
		node:walk(fn,id_depth)
	end
end

function TreeNode:dump()
	local result = {}
	result[#result+1] = string.format("%s,%s",self.seq,self.key)
	local function dump_(node,level)
		level = level or 1
		local space = string.rep("-", level)
		local len = node.child_list and #node.child_list or 0
		for i=1,len do
			local child_node = node.child_list[i]
			result[#result+1] = string.format("%s%s,%s",space,child_node.seq,child_node.key)
			dump_(child_node,level+1)
		end
	end
	dump_(self)
	local s = table.concat( result, "\n")
	print(s)
end

return TreeNode