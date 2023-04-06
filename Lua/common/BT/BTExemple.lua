--
-- @Author: ZensYue
-- @Date:   2022-05-22 17:31:26
--
local M = require "BehaviourTree"
local trace = print
--===============================
-- exemple
--*******************************
-- 生成节点
local LeafContexts = {}
for i=1,20 do
	local LeafContext = M.LeafContext:new()
	function LeafContext:OnEnter()
		trace(("执行 %s 准备"):format(i))
	end
	function LeafContext:OnExecute()
		trace(("执行 %s"):format(i))
		return true
	end
	function LeafContext:OnExit()
		-- trace(("LeafContext %s OnExit"):format(i))
		trace(("执行 %s 完毕"):format(i))
	end
	LeafContexts[i] = LeafContext
end

-- exemple Condition
local ConditionContexts = {}
for i=1,20 do
	local ConditionContext = M.ConditionContext:new()
	ConditionContext.id = 1
	ConditionContext.maxId = 1 + math.random(3)
	function ConditionContext:IsTrue()
		return self.id > self.maxId
	end
	function ConditionContext:Trick()
		self.id = self.id + 1
		if self:IsTrue() then
			trace(("条件%s达成,maxId = %s,id = %s"):format(i,self.maxId,self.id))
		end
	end
	function ConditionContext:Reset()
		self.id = 1
	end
	ConditionContexts[i] = ConditionContext
end


-- 测试顺序执行
local exempleBranchAction1 = M.Branch:new()
local exempleConditionAction1 = M.Condition:new(ConditionContexts[1],M.Leaf:new(LeafContexts[1]))
local exempleConditionAction2 = M.Condition:new(ConditionContexts[2],M.Leaf:new(LeafContexts[2]))
local exempleConditionAction3 = M.Condition:new(ConditionContexts[3],M.Leaf:new(LeafContexts[3]))

local SequenceContext1 = M.SequenceContext:new()
local actionSquence  = M.Sequence:new(SequenceContext1)
	:AddChild(exempleConditionAction1:SetName("测试条件"))	
	:AddChild(exempleBranchAction1:AddChild(exempleConditionAction2):AddChild(exempleConditionAction3):SetName("测试条件分支"))
	:AddChild(M.Leaf:new(LeafContexts[4]):SetName("测试顺序执行4"))
	:AddChild(M.Leaf:new(LeafContexts[5]):SetName("测试顺序执行5"))

trace("=========Squence==========")
trace("=========Squence==========")
trace("=========Squence==========")
actionSquence:Transition()
for i=1,20 do
	print("step " .. i)
	local status = actionSquence:Trick()
	if status == M.BTStatus.FINISHED then
		break
	end
end


trace("=========Repeat==========")
trace("=========Repeat==========")
trace("=========Repeat==========")
-- 测试循环
local RepeatContext1 = M.RepeatContext:new()
local RepeactAction = M.Repeat:new(RepeatContext1,3)
	:AddChild(M.Leaf:new(LeafContexts[5]):SetName("测试顺序执行5"))
	-- :AddChild(actionSquence) -- actionSquence上面已执行，算一次

RepeactAction:Transition()
for i=1,20 do
	print("step " .. i)
	local status = RepeactAction:Trick()
	if status == M.BTStatus.FINISHED then
		break
	end
end

trace("========= Spawn==========")
trace("========= Spawn==========")
trace("========= Spawn==========")
local SpawnContext1 = M.SpawnContext:new()
local SpawnAction = M.Spawn:new(SpawnContext1)
	:AddChild(M.Leaf:new(LeafContexts[6]):SetName("测试顺序执行6"))
	:AddChild(M.Leaf:new(LeafContexts[7]):SetName("测试顺序执行7"))

-- 测试并行
SpawnAction:Transition()
for i=1,20 do
	print("step " .. i)
	local status = SpawnAction:Trick()
	if status == M.BTStatus.FINISHED then
		break
	end
end

--*******************************
-- exemple
--===============================