--------------------------------------------------------------------------------
--      Copyright (c) 2022 , ZensYue ZensYue@163.com
--      All rights reserved.
--      Use, modification and distribution are subject to the "MIT License"
--------------------------------------------------------------------------------

local setmetatable = setmetatable
local getmetatable = getmetatable
local type = type
local table = table
local pairs = pairs
local ipairs = ipairs
local string = string
local print = print
local insert = table.insert
local assert = assert

local M = {
	Debug = true,
}

local inherit = function (child, parent)
    setmetatable(child, parent)
end

local super = function (child)
    return getmetatable(child)
end

local ERROR_TEMPLATE = "%s must be a %s, got: %s"
local assertType = function(obj, expectedType, name, returnStr)
	assert(type(expectedType) == 'string' and type(name) == 'string')
	if type(obj) ~= expectedType then
		local s = ERROR_TEMPLATE:format(name, expectedType, tostring(obj))
		if returnStr then
			s = s .. ", return " .. returnStr
		end
		error(s, 2)
	end
end

local trace = function(...)
	if M.Debug then
		print(...)
	end
end

local _id = 0
local getId = function()
	_id = _id + 1
	return _id
end

--===============================
-- status
--*******************************
local BTStatus = {
	-- status
	WAITING	    = 1,
	EXECUTING   = 1,
    FINISHED    = 2,
    TRANSITION  = 3,
    NOTDATA  	= 4,
}
--*******************************
-- status
--===============================


--===============================
-- Tree Node
--*******************************
local BTTreeNode = {}
BTTreeNode.__index = BTTreeNode

function BTTreeNode:new()
	local t = {_childrens = {},_childCount = 0,_maxChildCount = -1}
	local o =  setmetatable(t, self)
	o:__init()
	return o
end

function BTTreeNode:GetTypeName()
	return "BTTreeNode"
end

function BTTreeNode:__init()
	-- self._childrens = {}
	-- self._childCount = 0
end

function BTTreeNode:AddChild(treeNode)
	if self._maxChildCount >= 0 and self._childCount >= self._maxChildCount then
        error(("%s exceeding child count,max child count = %s , cur child count"):format(self:GetTypeName(),self._maxChildCount,self._childCount))
        return self
    end
    insert(self._childrens,treeNode)
    self._childCount = self._childCount + 1
    return self
end

function BTTreeNode:GetChildCount()
	return self._childCount
end

function BTTreeNode:GetChild(index)
	return self._childrens[index]
end
--*******************************
-- Tree Node
--===============================


--===============================
-- Action
--*******************************
local BTAction = {}
BTAction.__index = BTAction
inherit(BTAction,BTTreeNode)

function BTAction:new(context)
	local t = super(BTAction).new(self)
	t._id = getId()
	t._precondition = nil
	if M.Debug and context then
		assertType(context.Transition,"function","Transition")
		t:CheckContext(context)
	end
	t._context = context
	return t
end

function BTAction:GetTypeName()
	return "BTAction"
end

function BTAction:__init()
	super(BTAction).__init(self)
	self._state = BTStatus.WAITING
end

function BTAction:SetName(value)
	self._name = value
	return self
end

function BTAction:GetName()
	return self._name
end

function BTAction:GetId()
	return self._id
end

-- function BTAction:SetCondition(condition)
-- 	self._precondition = condition
-- 	return self
-- end

-- if true,Trick
function BTAction:Evaluate()
	-- return (not self._precondition or self._precondition:IsTrue()) and self:OnEvaluate()
	return self:OnEvaluate()
end

function BTAction:Transition()
	if self._context then
		self._context:Transition()
	end
	self:OnTransition()
	return self
end

function BTAction:Trick(dt)
	-- if not self._context then
	-- 	return BTStatus.NOTDATA
	-- end
	if self._state == BTStatus.FINISHED then
		return self._state
	end
	self._state = self:OnTrick(dt)
	return self._state
end

function BTAction:Reset()
	self:OnReset()
end

function BTAction:GetContext()
	return self._context
end

-- need override
function BTAction:CheckContext(context)
end

-- need override
function BTAction:OnEvaluate()
	return true
end

-- need override
function BTAction:OnTrick()
	return BTStatus.FINISHED
end

-- need override
function BTAction:OnTransition()
end

-- need override
function BTAction:OnReset()
	self._state = BTStatus.WAITING
	if self._context then
		self._context:Reset()
	end

	for i=1,self._childCount do
		local action = self._childrens[i]
		if action then
			action:Reset()
		end
	end
end

-- Action Context base
local BTActionContext = {}
BTActionContext.__index = BTActionContext

function BTActionContext:new()
	local o =  setmetatable({}, self)
	return o
end

-- need override
function BTActionContext:Transition()
end
-- need override
function BTActionContext:Reset()
end
--*******************************
-- Action
--===============================


--===============================
-- BTActionLeaf 普通节点
--*******************************
local BTActionLeafStatus = {
	ACTION_READY = 1,
    ACTION_RUNNING = 2,
    ACTION_FINISHED = 3,
}

local BTActionLeaf = {}
BTActionLeaf.__index = BTActionLeaf
inherit(BTActionLeaf,BTAction)

function BTActionLeaf:new(context)
	local t = super(BTActionLeaf).new(self,context)
	return t
end

function BTActionLeaf:GetTypeName()
	return "BTActionLeaf"
end

function BTActionLeaf:__init()
	super(BTActionLeaf).__init(self)
	self._maxChildCount = 0
end

function BTActionLeaf:OnTrick(dt)
	local status = BTStatus.TRANSITION
	if self._context.status == BTActionLeafStatus.ACTION_READY then
		self._context:OnEnter()
		self._context.status = BTActionLeafStatus.ACTION_RUNNING
		status = BTStatus.TRANSITION
	end

	if self._context.status == BTActionLeafStatus.ACTION_RUNNING then
		if self._context:OnExecute(dt) then
			self._context.status = BTActionLeafStatus.ACTION_FINISHED
		end
	end

	if self._context.status == BTActionLeafStatus.ACTION_FINISHED then
		self._context:OnExit()
		status = BTStatus.FINISHED
	end
	return status
end

function BTActionLeaf:OnTransition()
	self._context.status = BTActionLeafStatus.ACTION_READY
end


function BTActionLeaf:CheckContext(context)
	assertType(context.status,"number","status(1 ready,2 running,3 finished)")
	assertType(context.OnEnter,"function","OnEnter")
	assertType(context.OnExecute,"function","OnExecute","bool")
	assertType(context.OnExit,"function","OnExit")
end

-- Leaf Context
local BTActionLeafContext = {}
BTActionLeafContext.__index = BTActionLeafContext
inherit(BTActionLeafContext,BTActionContext)

function BTActionLeafContext:new()
	local t = {status = BTActionLeafStatus.ACTION_READY}
	local o =  setmetatable(t, BTActionLeafContext)
	return o
end

function BTActionLeafContext:Reset()
	self.status = BTActionLeafStatus.ACTION_READY
end

-- contain OnEnter function
function BTActionLeafContext:Transition()
end

-- contain OnEnter function
function BTActionLeafContext:OnEnter()
end

-- contain OnExecute function
function BTActionLeafContext:OnExecute()
	return true
end

-- contain OnExit function
function BTActionLeafContext:OnExit()
end
--*******************************
-- BTActionLeaf
--===============================


--===============================
-- BTActionLoop 重复
--*******************************
local BTActionLoop = {INFINITY = -1}
BTActionLoop.__index = BTActionLoop
inherit(BTActionLoop,BTAction)

function BTActionLoop:new(context,loopCount)
	local t = super(BTActionLoop).new(self,context)
	t:SetLoopCount(loopCount)
	return t
end

function BTActionLoop:GetTypeName()
	return "BTActionLoop"
end

function BTActionLoop:__init()
	super(BTActionLoop).__init(self)
	self._maxChildCount = 1
	self._loopCount = BTActionLoop.INFINITY
end

function BTActionLoop:SetLoopCount(count)
	self._loopCount = count
	return self
end

function BTActionLoop:OnEvaluate()
	local checkCount = self._loopCount == BTActionLoop.INFINITY or self._context.currentCount < self._loopCount
	if not checkCount then
		return false
	end
	local action = self:GetChild(1)
	if action then
		return action:Evaluate()
	end
	return false
end

function BTActionLoop:OnTrick()
	local status = BTStatus.TRANSITION
	local action = self:GetChild(1)
	if action then
		local action_status = action:Trick()
		if action_status == BTStatus.FINISHED then
			self._context.currentCount = self._context.currentCount + 1
			if self._loopCount == BTActionLoop.INFINITY or self._context.currentCount < self._loopCount then
				action:Reset()
				status = BTStatus.EXECUTING
			else
				status = BTStatus.FINISHED
			end
		end
	end
	return status
end

function BTActionLoop:OnTransition()
	local action = self:GetChild(1)
	if action then
		action:Transition()
	end
	self._context.currentCount = 0
end

function BTActionLoop:CheckContext(context)
	assertType(context.currentCount,"number","currentCount")
	assertType(context.Reset,"function","Reset")
end

-- Loop Context
local BTActionLoopContext = {}
BTActionLoopContext.__index = BTActionLoopContext
inherit(BTActionLoopContext,BTActionContext)

function BTActionLoopContext:new(...)
	local t = {currentCount = 0}
	local o =  setmetatable(t, self)
	return o
end

function BTActionLoopContext:Transition()
end

-- contain Reset function
function BTActionLoopContext:Reset()
	self.currentCount = 0
end
--*******************************
-- BTActionLoop
--===============================



--===============================
-- BTActionPrioritizedSelector 选择
--*******************************
local BTActionPrioritizedSelector = {}
BTActionPrioritizedSelector.__index = BTActionPrioritizedSelector
inherit(BTActionPrioritizedSelector,BTAction)

function BTActionPrioritizedSelector:new(context)
	local t = super(BTActionPrioritizedSelector).new(self,context)
	return t
end

function BTActionPrioritizedSelector:GetTypeName()
	return "BTActionPrioritizedSelector"
end

function BTActionPrioritizedSelector:__init()
	super(BTActionPrioritizedSelector).__init(self)
	self._maxChildCount = -1
	self._nonParioritized = false
end

function BTActionPrioritizedSelector:SetPrioritizedState(bo)
	self._nonParioritized = bo
end

function BTActionPrioritizedSelector:SetSelectedIndex(index)
	self._context.currentSelectedIndex = index
	return self
end

function BTActionPrioritizedSelector:OnEvaluate()
	if self._nonParioritized then
		local action = self:GetChild(self._context.currentSelectedIndex)
		if action then
			return action:Evaluate()
		end
		return false
	end
	self._context.currentSelectedIndex = -1
	for i=1,self._childCount do
		local action = self._childrens[i]
		if action:Evaluate() then
			self._context.currentSelectedIndex = i
			return true
		end
	end
	return false
end

function BTActionPrioritizedSelector:OnTrick()
	if self._context.currentSelectedIndex ~= self._context.lastSelectedIndex then
		self._context.lastSelectedIndex = self._context.currentSelectedIndex
		local action = self:GetChild(self._context.lastSelectedIndex)
		if action then
			action:Transition()
		end
	end
	local status = BTStatus.FINISHED
	local action = self:GetChild(self._context.lastSelectedIndex)
	if action then
		status = action:Trick()
		if status == BTStatus.FINISHED then
			self._context.currentSelectedIndex = -1
		end
	end
	return status
end

function BTActionPrioritizedSelector:OnTransition()
	local action = self:GetChild(self._context.lastSelectedIndex)
	if action then
		action:Transition()
	end
	self._context.lastSelectedIndex = -1
end

function BTActionPrioritizedSelector:TransitionChild(context,index)
	index = index or self._context.currentSelectedIndex
	local action = self:GetChild(index)
	if action then
		-- action:Transition(context)
	end
end

function BTActionPrioritizedSelector:CheckContext(context)
	assertType(context.currentSelectedIndex,"number","currentSelectedIndex")
	assertType(context.lastSelectedIndex,"number","lastSelectedIndex")
end

-- Selector Context
local BTActionPrioritizedSelectorContext = {}
BTActionPrioritizedSelectorContext.__index = BTActionPrioritizedSelectorContext
inherit(BTActionPrioritizedSelectorContext,BTActionContext)

function BTActionPrioritizedSelectorContext:new(...)
	local t = {currentSelectedIndex = -1,lastSelectedIndex = -1}
	local o =  setmetatable(t, self)
	return o
end

function BTActionPrioritizedSelectorContext:Reset()
	self.currentSelectedIndex = -1
	self.currentSelectedIndex = -1
end
--*******************************
-- BTActionPrioritizedSelector
--===============================



--===============================
-- Sequence 顺序
--*******************************
local BTActionSequence = {}
BTActionSequence.__index = BTActionSequence
inherit(BTActionSequence,BTAction)

function BTActionSequence:new(context)
	local t = super(BTActionSequence).new(self,context)
	return t
end

function BTActionSequence:GetTypeName()
	return "BTActionSequence"
end

function BTActionSequence:__init()
	super(BTActionSequence).__init(self)
end

function BTActionSequence:OnEvaluate()
	local checkNodeIndex = -1
	local action = self:GetChild(self._context.currentSelectedIndex)
	if action then
		checkNodeIndex = self._context.currentSelectedIndex
	else
		checkNodeIndex = 1
	end
	action = self:GetChild(checkNodeIndex)
	if action then
		local bo = action:Evaluate()
		if bo then
			self._context.currentSelectedIndex = checkNodeIndex
			return true
		end
	end
	return false
end

function BTActionSequence:OnTrick(dt)
	local status = BTStatus.TRANSITION
	local action = self:GetChild(self._context.currentSelectedIndex)
	if action then
		status = action:Trick(dt)
		if status == BTStatus.FINISHED then
			self._context.currentSelectedIndex = self._context.currentSelectedIndex + 1
			local new_action = self:GetChild(self._context.currentSelectedIndex)
			if not new_action then
				status = BTStatus.FINISHED
				self._context.currentSelectedIndex = -1
			else
				new_action:Transition()
				status = BTStatus.TRANSITION
			end
		end
	end
	return status
end

function BTActionSequence:OnTransition()
	local action = self:GetChild(self._context.currentSelectedIndex)
	if action then
		action:Transition()
	end
end

function BTActionSequence:CheckContext(context)
	assertType(context.currentSelectedIndex,"number","currentSelectedIndex")
end

-- Sequence Context
local BTActionSequenceContext = {}
BTActionSequenceContext.__index = BTActionSequenceContext
inherit(BTActionSequenceContext,BTActionContext)

function BTActionSequenceContext:new(...)
	local t = {currentSelectedIndex = 1}
	local o =  setmetatable(t, BTActionSequenceContext)
	return o
end

function BTActionSequenceContext:Reset()
	self.currentSelectedIndex = 1
end
--*******************************
-- Sequence
--===============================




--===============================
-- Spawn 并行
--*******************************
local BTActionSpawn = {}
BTActionSpawn.__index = BTActionSpawn
inherit(BTActionSpawn,BTAction)

function BTActionSpawn:new(context)
	local t = super(BTActionSpawn).new(self,context)
	return t
end

function BTActionSpawn:GetTypeName()
	return "BTActionSpawn"
end

function BTActionSpawn:__init()
	super(BTActionSpawn).__init(self)
end

function BTActionSpawn:OnEvaluate()
	if self._childCount == 0 then
		return false
	end
	for i=1,self._childCount do
		local action = self._childrens[i]
		local bo = action:Evaluate()
		if not bo then
			return false
		end
	end
	return true
end

function BTActionSpawn:OnTrick()
	local status = BTStatus.FINISHED
	for i=1,self._childCount do
		local action = self._childrens[i]
		local action_status = action:Trick()
		if action_status ~= BTStatus.FINISHED and status == BTStatus.FINISHED then
			status = BTStatus.TRANSITION
		end
	end
	return status
end

function BTActionSpawn:OnTransition()
	for i=1,self._childCount do
		local action = self._childrens[i]
		action:Transition()
	end
end

function BTActionSpawn:CheckContext(context)
end

-- Spawn Context
local BTActionSpawnContext = {}
BTActionSpawnContext.__index = BTActionSpawnContext
inherit(BTActionSpawnContext,BTActionContext)

function BTActionSpawnContext:new(...)
	local t = {}
	local o =  setmetatable(t, BTActionSpawnContext)
	return o
end
--*******************************
-- Spawn
--===============================


--===============================
-- Condition 条件
--*******************************
local BTActionCondition = {}
BTActionCondition.__index = BTActionCondition
inherit(BTActionCondition,BTAction)

function BTActionCondition:new(context,action)
	local t = super(BTActionCondition).new(self,context)
	t._action = action
	return t
end

function BTActionCondition:GetTypeName()
	return "BTActionCondition"
end

function BTActionCondition:__init()
	super(BTActionCondition).__init(self)
	self._evaluate = false
end

-- function BTActionCondition:SetEvaluate(value)
-- 	self._evaluate = value
-- end
-- function BTActionCondition:GetEvaluate()
-- 	return self._evaluate
-- end

-- function BTActionCondition:OnEvaluate()
-- 	return self._action:Evaluate()
-- end

function BTActionCondition:IsTrue()
	return self._evaluate
end

function BTActionCondition:CheckContext(context)
	assertType(context.Trick,"function","Trick")
	assertType(context.IsTrue,"function","IsTrue","bool")
end

function BTActionCondition:OnTrick()
	if not self._evaluate then
		self._context:Trick()
		self._evaluate = self._context:IsTrue()
		return BTStatus.TRANSITION
	end
	return self._action:Trick()
end

function BTActionCondition:OnReset()
	super(BTActionCondition).OnReset(self)
	self._evaluate = false
end

-- Condition Context
local BTActionConditionContext = {}
BTActionConditionContext.__index = BTActionConditionContext
inherit(BTActionConditionContext,BTActionContext)

function BTActionConditionContext:new(...)
	local t = {}
	local o =  setmetatable(t, self)
	return o
end

function BTActionConditionContext:IsTrue()
	return true
end
function BTActionConditionContext:Trick()
end
--*******************************
-- Condition
--===============================

--===============================
-- Branch 分支，结合条件使用
--*******************************
local BTActionBranch = {}
BTActionBranch.__index = BTActionBranch
inherit(BTActionBranch,BTAction)

function BTActionBranch:new(context)
	local t = super(BTActionBranch).new(self,context)
	t._action = nil
	return t
end

function BTActionBranch:GetTypeName()
	return "BTActionBranch"
end

function BTActionBranch:__init()
	super(BTActionBranch).__init(self)
end

function BTActionBranch:CheckContext(context)
end

function BTActionBranch:AddChild(treeNode)
	if M.Debug then
		assertType(treeNode.IsTrue,"function","IsTrue","bool")
	end
	super(BTActionBranch).AddChild(self,treeNode)
	return self
end

function BTActionBranch:OnTrick()
	local status = BTStatus.TRANSITION
	if not self._action then
		for i=1,self._childCount do
			local action = self._childrens[i]
			-- run context trick
			action:Trick()
			if action:IsTrue() then
				status = BTStatus.TRANSITION
				self._action = action
				-- break
				return status
			end
		end
	end

	if self._action then
		local action_status = self._action:Trick()
		return action_status
	end
	return status
end

function BTActionBranch:OnTransition()
	for i=1,self._childCount do
		local action = self._childrens[i]
		local bo = action:Evaluate()
		action:Transition()
	end
end

-- Branch Context
local BTActionBranchContext = {}
BTActionBranchContext.__index = BTActionBranchContext
inherit(BTActionBranchContext,BTActionContext)

function BTActionBranchContext:new(...)
	local t = {}
	local o =  setmetatable(t, BTActionBranchContext)
	return o
end
--*******************************
-- Branch
--===============================


local _M = {
	BTStatus = BTStatus,

	Leaf = BTActionLeaf,
	LeafStatus = BTActionLeafStatus,
	LeafContext = BTActionLeafContext,

	Repeat = BTActionLoop,
	RepeatContext = BTActionLoopContext,

	Selector = BTActionPrioritizedSelector,
	SelectorContext = BTActionPrioritizedSelectorContext,

	Sequence = BTActionSequence,
	SequenceContext = BTActionSequenceContext,

	Spawn = BTActionSpawn,
	SpawnContext = BTActionSpawnContext,

	Condition = BTActionCondition,
	ConditionContext = BTActionConditionContext,

	Branch = BTActionBranch,
	BranchContext = BTActionBranchContext,
}

setmetatable(M, {__index = _M})
return M
