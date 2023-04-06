--- 测试订阅功能

local UnitTest_Subscribe = UnitTest.New()

UnitTest_Subscribe.Node = {}

--- 测试 普通订阅 SubscribeType.NORMAL
--- 当 test1 值发生变化时，会回调。触发回调边界为 >= 3
function UnitTest_Subscribe.Node:TestNormal()
    g_SubscribeMgr:Reset()

    ---@param node SubscribeNode
    local function callback(node,bo)
        print("TestNormal ",node.name,node:GetValue(),bo)
    end

    local key1 = "test1"
    g_SubscribeMgr:UpdateValue(key1,2)

    local node1 = g_SubscribeMgr:CreateNode(key1,3,callback,SubscribeType.NORMAL)
    node1.name = "name1"
    g_SubscribeMgr:UpdateValue(key1,1)
    g_SubscribeMgr:UpdateValue(key1,2)
    g_SubscribeMgr:UpdateValue(key1,3)
    g_SubscribeMgr:UpdateValue(key1,4)
    g_SubscribeMgr:UpdateValue(key1,2)
    g_SubscribeMgr:UpdateValue(key1,1)

    g_SubscribeMgr:RemoveNode(node1)
end

--- 测试 增量订阅 SubscribeType.INCREMENT
--- 当 test1 值发生变化时，会回调。触发回调边界为变化值 >= 3
function UnitTest_Subscribe.Node:TestIncrementAndReset()
    g_SubscribeMgr:Reset()

    local node1,node2
    ---@param node SubscribeNode
    local function callback(node,bo)
        print("TestNormal ",node.name,node:GetValue(),bo)
        if node == node1 then
            node:ResetTarget()
        end

        if node == node2 then
            node:ResetTarget(nil,true)
        end
    end

    local key1 = "test1"
    g_SubscribeMgr:UpdateValue(key1,3)

    node1 = g_SubscribeMgr:CreateNode(key1,3,callback,SubscribeType.INCREMENT)
    node1.name = "node1"
    node2 = g_SubscribeMgr:CreateNode(key1,3,callback,SubscribeType.INCREMENT)
    node2.name = "node2"
    g_SubscribeMgr:UpdateValue(key1,4)
    g_SubscribeMgr:UpdateValue(key1,5)
    g_SubscribeMgr:UpdateValue(key1,6)
    g_SubscribeMgr:UpdateValue(key1,6)
    g_SubscribeMgr:UpdateValue(key1,9)


    g_SubscribeMgr:RemoveNode(node1)
    g_SubscribeMgr:RemoveNode(node2)
end


--- 测试 小于等于订阅 SubscribeType.LessThan
--- 当 test1 值发生变化时，会回调。触发回调边界为 <= 3
function UnitTest_Subscribe.Node:TestLessThan()
    g_SubscribeMgr:Reset()

    ---@param node SubscribeNode
    local function callback(node,bo)
        print("TestLessThan ",node.name,node:GetValue(),bo)
    end

    local key1 = "test1"
    g_SubscribeMgr:UpdateValue(key1,2)

    local node1 = g_SubscribeMgr:CreateNode(key1,3,callback,SubscribeType.LessThan)
    node1.name = "name1"
    g_SubscribeMgr:UpdateValue(key1,2)
    g_SubscribeMgr:UpdateValue(key1,3)
    g_SubscribeMgr:UpdateValue(key1,4)
    g_SubscribeMgr:UpdateValue(key1,2)

    g_SubscribeMgr:RemoveNode(node1)
end

--- 测试订阅组合功能
UnitTest_Subscribe.Group = {}

--- 测试组合 Add &。同时满足多个条件
function UnitTest_Subscribe.Group:TestGroupAnd()
    g_SubscribeMgr:Reset()

    local groupNode
    ---@param group SubscribeGroup
    local function callback(group,bo)
        print("TestGroupAnd group ",bo,group:IsFinish())
    end
    groupNode = g_SubscribeMgr:CreateGroup(callback,SubscribeType.GROUP_AND)
    g_SubscribeMgr:AddGroupNode(groupNode,"test1",3,SubscribeType.INCREMENT)
    g_SubscribeMgr:AddGroupNode(groupNode,"test2",3,SubscribeType.INCREMENT)
    local key1 = "test1"
    g_SubscribeMgr:UpdateValue(key1,3)

    local key2 = "test2"
    g_SubscribeMgr:UpdateValue(key2,3)
    g_SubscribeMgr:UpdateValue(key2,2)

    g_SubscribeMgr:RemoveGroup(groupNode)
end

--- 测试组合 Or |。满足多个条件中的一个
function UnitTest_Subscribe.Group:TestGroupOr()
    g_SubscribeMgr:Reset()

    local groupNode
    ---@param group SubscribeGroup
    local function callback(group,bo)
        print("TestGroupOr group ",bo,group:IsFinish())
    end
    groupNode = g_SubscribeMgr:CreateGroup(callback,SubscribeType.GROUP_OR)
    g_SubscribeMgr:AddGroupNode(groupNode,"test1",3,SubscribeType.INCREMENT)
    g_SubscribeMgr:AddGroupNode(groupNode,"test2",3,SubscribeType.INCREMENT)
    local key1 = "test1"
    g_SubscribeMgr:UpdateValue(key1,3)

    local key2 = "test2"
    g_SubscribeMgr:UpdateValue(key2,3)

    g_SubscribeMgr:UpdateValue(key1,2)
    g_SubscribeMgr:UpdateValue(key2,2)

    g_SubscribeMgr:RemoveGroup(groupNode)
end

--- 组 综合测试
function UnitTest_Subscribe.Group:TestGroup()
    g_SubscribeMgr:Reset()

    ---@type SubscribeGroup
    local groupNode
    ---@param group SubscribeGroup
    local function callback(group,bo)
        local isFinish = group:IsFinish()
        print("TestGroupOr group ",bo,isFinish)
    end
    groupNode = g_SubscribeMgr:CreateGroup(callback,SubscribeType.GROUP_AND)
    g_SubscribeMgr:AddGroupNode(groupNode,"test1",3,SubscribeType.Equal)

    local newGroup = g_SubscribeMgr:AddGroup(groupNode,SubscribeType.GROUP_OR)
    g_SubscribeMgr:AddGroupNode(newGroup,"test2",3,SubscribeType.Equal)
    g_SubscribeMgr:AddGroupNode(newGroup,"test2",2,SubscribeType.Equal)

    local key1 = "test1"
    g_SubscribeMgr:UpdateValue(key1,3)

    local key2 = "test2"
    g_SubscribeMgr:UpdateValue(key2,3)

    local key3 = "test3"
    g_SubscribeMgr:UpdateValue(key3,3)

    -- g_SubscribeMgr:UpdateValue(key1,2)
    g_SubscribeMgr:UpdateValue(key2,2)
    g_SubscribeMgr:UpdateValue(key2,1)


    g_SubscribeMgr:RemoveGroup(groupNode)
end
UnitTest_Subscribe.Run()