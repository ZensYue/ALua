--- 测试委托

local UnitTest_10_Delegate = UnitTest.New()

function  UnitTest_10_Delegate:Test_Call()
    local function fn1(...)
        print("Test_Call fn1",...)
    end

    local function fn2(...)
        print("Test_Call fn2",...)
    end

    local delegate = g_DelegateMgr:Create(fn1,1)
    delegate:Add(fn2)

    g_DelegateMgr:Call(delegate:GetID(),1)
    g_DelegateMgr:Call(delegate:GetID(),2)
end

--- 测试操作符 +-
function  UnitTest_10_Delegate:Test_Operator()
    local function fn1(...)
        print("Test_Operator fn1",...)
    end

    local function fn2(...)
        print("Test_Operator fn2",...)
    end

    local delegate = g_DelegateMgr:Create(fn1)
    
    g_DelegateMgr:Call(delegate:GetID(),1)

    delegate = delegate + fn2
    delegate = delegate - fn1
    g_DelegateMgr:Call(delegate:GetID(),2)

    delegate(3)
end

--- 测试GC1
function  UnitTest_10_Delegate:Test_GC1()
    local function fn1(...)
        print("Test_GC1 fn1",...)
    end

    local function Test(delegate)
        local function fn2(...)
            print("Test_GC1 fn2",...)
        end
        delegate = delegate + fn2
    end
    local delegate = DelegateNode.New(fn1)
    Test(delegate)

    delegate(1)
    collectgarbage()
    delegate:Call(2)
end

--- 测试GC2
function  UnitTest_10_Delegate:Test_GC2()
    local function fn1(...)
        print("Test_GC2 fn1",...)
    end

    local function fn3(...)
        print("Test_GC2 fn3",...)
    end

    local function Test()
        local function fn2(...)
            print("Test_GC2 fn2",...)
        end
        return DelegateNode.New(fn2)
    end
    local delegate = Test()

    delegate = delegate + fn1
    delegate(1)
    collectgarbage()
    delegate:Call(2)
    delegate:Add(fn3)
    delegate:Call(3)
end

--- 测试GC3
function  UnitTest_10_Delegate:Test_GC3()
    local function fn1(...)
        print("Test_GC3 fn1",...)
    end

    local function fn3(...)
        print("Test_GC3 fn3",...)
    end

    local function fn4(...)
        print("Test_GC3 fn4",...)
    end

    local function fn5(...)
        print("Test_GC3 fn5",...)
    end

    local function Test()
        local function fn2(...)
            print("Test_GC3 fn2",...)
        end
        local delegate =  g_DelegateMgr:Create(fn2)
        delegate = delegate + fn1
        return delegate:GetID()
    end
    
    g_DelegateMgr:Create(fn3)
    local delegate = g_DelegateMgr:Create(fn4)
    print("Test_GC3 delegate ",delegate:GetID())
    g_delegate = g_DelegateMgr:Create(fn5)
    print("Test_GC3 g_delegate ",g_delegate:GetID())

    local ids = {}
    for id, value in pairs(g_DelegateMgr.m_DelegateList) do
        print("g_DelegateMgr.m_DelegateList ",id,value)
        table.insert(ids,id)
    end

    local id = Test()

    g_DelegateMgr:Call(id,1)
    collectgarbage()
    print("Test_GC3 collectgarbage ")
    g_DelegateMgr:Call(id,2)
    for id, value in pairs(g_DelegateMgr.m_DelegateList) do
        print("g_DelegateMgr.m_DelegateList ",id,value)
    end

    for _, id in pairs(ids) do
        g_DelegateMgr:Call(id,id)
    end
end

UnitTest_10_Delegate.Run()