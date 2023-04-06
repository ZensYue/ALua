
--- 测试object

---@class TestObject:object
local TestObject = Aclass("TestObject", object)

function TestObject:ctor()
    print("TestObject ctor")
    self.m_Time = 0
end

function TestObject:dctor()
    print("TestObject dctor")
end

function TestObject:StartOnceTime(...)
    object.StartOnceTime(self,...)
end

function TestObject:StartTestTime()
    self:StartTime(true,"TestTime","HelloWord",1,10)
end

function  TestObject:StartTestEvent(key)
    self:AddEvent(key,"TestEvent")
    g_Event:Brocast(key,1,2,3)
end

function  TestObject:TestTime(...)
    self.m_Time = self.m_Time + 1
    print("TestObject:TestTime ",self.m_Time,...)
end

function  TestObject:TestEvent(...)
    print("TestObject:TestEvent ",...)
end

function TestObject:StartTestDelegate()
    local delegate1 = self:CreateDelegate("TestDelegate","a")
    local delegate2 = self:CreateDelegate("TestDelegate","a",1)
    print("StartTestDelegate ",delegate1 == delegate2)
    g_DelegateMgr:Call(delegate1:GetID(),"delegate1",1)
    g_DelegateMgr:Call(delegate1:GetID(),"delegate1",2)
    g_DelegateMgr:Call(delegate1:GetID(),"delegate1",3)
    
    g_DelegateMgr:Call(delegate2:GetID(),"delegate2",1)
    g_DelegateMgr:Call(delegate2:GetID(),"delegate2",2)
    g_DelegateMgr:Call(delegate2:GetID(),"delegate2",3)
end

function TestObject:TestDelegate(...)
    print("TestObject:TestDelegate ",...)
end


local UnitTest_11_Object = UnitTest.New()

function UnitTest_11_Object:TestObject()
    object.checkislegal = true
    local obj1 = TestObject.New()
    obj1:StartTestTime()
    obj1:StartTestEvent("TestEvent")
    UnitTestUpdate(20)

    obj1:StartTestDelegate()
    
    print("TestObject obj1 __m_events",obj1.__m_events)
    print("TestObject obj1 __m_times",obj1.__m_times)
    print("TestObject obj1 __m_handlers",obj1.__m_handlers)
    print("TestObject obj1 __m_handlers_p",obj1.__m_handlers_p)
    print("TestObject obj1 __m_delegates",obj1.__m_delegates)

    obj1:Delete()

    print("TestObject obj1 __m_events",obj1.__m_events)
    print("TestObject obj1 __m_times",obj1.__m_times)
    print("TestObject obj1 __m_handlers",obj1.__m_handlers)
    print("TestObject obj1 __m_handlers_p",obj1.__m_handlers_p)
    print("TestObject obj1 __m_delegates",obj1.__m_delegates)
end

UnitTest_11_Object.Run()