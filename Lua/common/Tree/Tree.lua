--------------------------------------------------------------------------------
--      Copyright (c) 2023 , ZensYue ZensYue@163.com
--      All rights reserved.
--      Use, modification and distribution are subject to the "MIT License"
--------------------------------------------------------------------------------

--- 树结构
---@class Tree
local Tree = Aclass("Tree")

function Tree:ctor(data,pos,node_cls)
	self.node_cls = node_cls or TreeNode
	self.index = 0
	self.top_node = self:addnode(nil,pos,data)
end

---@param data ReddotData
---@return TreeNode
function Tree:addnode(parent_node,key,data)
	parent_node = parent_node or self.top_node
	---@type TreeNode
	local node = self.node_cls.New(parent_node,key)
	if parent_node then
		parent_node:addchild(node)
	end
	node.id = self.index
	--local seq = node.seq
	--local key = node.key
	node:setdata(data)

	self.index = self.index + 1
	return node
end

function Tree:findnode(seq,key)
	if not seq and TreeNode.islist(key) then
		assert(false,"tree.findnode param is error,the param is " .. tostring(seq) .. "," .. tostring(key))
		return nil
	end
	return self.top_node:findchild(seq,key)
end

function Tree:remove(seq,key)
	local node = self:findnode(seq,key)
	self:removenode(node)
end

function Tree:removenode(node)
	local parent_node = node.parent_node
	if parent_node then
		parent_node:removechilde(node)
	else
		node:Delete()
	end
end

function Tree:walk(fn,id_depth)
	self.top_node:walk(fn,id_depth)
end

function Tree:dump()
	self.top_node:dump()
end

return Tree