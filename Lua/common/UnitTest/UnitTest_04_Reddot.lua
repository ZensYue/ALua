
--- 测试红点

local UnitTest_04_Reddot = UnitTest.New()

--- 测试红点 树图
function  UnitTest_04_Reddot:TestParent()
    UnitTestUpdate(1)

    local reddotKey1 = "a1_b_c1"
    local reddotKey2 = "a1_b_c2"
    local function f(key,value)
        print("TestParent ",key,value)
    end
    local event_id = g_Event:Add("UpdateReddot",f)

    g_ReddotTreeMgr:SetNodeNum(reddotKey1,1)
    print("TestParent SetNodeNum Time 1")
    UnitTestUpdate(1)
    print("TestParent SetNodeNum Time 2")
    g_ReddotTreeMgr:SetNodeNum(reddotKey1,0)
    UnitTestUpdate(1)
    print("TestParent SetNodeNum Time 3")
    g_ReddotTreeMgr:SetNodeNum(reddotKey2,1)
    UnitTestUpdate(1)

    g_Event:Remove(event_id)
end


--- 测试显示类型
function  UnitTest_04_Reddot:TestShowType()
    UnitTestUpdate(1)

    local reddotKey1 = "a2_b_c1"
    local function f(key,value)
        print("TestShowType ",key,value)
    end
    local event_id = g_Event:Add("UpdateReddot",f)

    g_ReddotTreeMgr:SetNodeShowType(reddotKey1,ReddotType.ShowType.LoginOnce)

    print("TestShowType SetNodeNum Time 1")
    g_ReddotTreeMgr:SetNodeNum(reddotKey1,1)
    UnitTestUpdate(1)
    print("TestShowType SetNodeNum Time 2")
    g_ReddotTreeMgr:SetNodeNum(reddotKey1,0)
    UnitTestUpdate(1)
    print("TestShowType SetNodeNum Time 3")
    g_ReddotTreeMgr:SetNodeNum(reddotKey1,1)
    UnitTestUpdate(1)

    g_Event:Remove(event_id)
end

--- 测试值类型
function  UnitTest_04_Reddot:TestValueType()
    UnitTestUpdate(1)

    local reddotKey1 = "a3_b_c1"
    local reddotKey2 = "a3_b_c2"
    local function f(key,value)
        print("TestValueType ",key,value)
    end
    local event_id = g_Event:Add("UpdateReddot",f)

    g_ReddotTreeMgr:SetNodeType(reddotKey1,ReddotType.ValueType.Number)

    print("TestValueType SetNodeNum Time 1")
    g_ReddotTreeMgr:SetNodeNum(reddotKey1,1)
    g_ReddotTreeMgr:SetNodeNum(reddotKey2,1)
    UnitTestUpdate(1)
    print("TestValueType SetNodeNum Time 2")
    g_ReddotTreeMgr:SetNodeNum(reddotKey1,2)
    g_ReddotTreeMgr:SetNodeNum(reddotKey2,2)
    UnitTestUpdate(1)

    g_Event:Remove(event_id)
end

UnitTest_04_Reddot.Run()