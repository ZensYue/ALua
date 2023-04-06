--- 测试定时器和常用事件方法

local UnitTest_01_Time = UnitTest.New()

-- 获取本地时区
function UnitTest_01_Time:TestZoneTime()
    print("local zone time : ",timeutil.getlocaltimezoneindex())
end

--- 测试循环定时器
function UnitTest_01_Time:TestTimerLoop()
    local id,callback
    local count = 0
    callback = function()
        count = count + 1
        print("TestTimerLoop " .. count)
        if count >= 10 then
            g_Timer:Stop(id)
        end
    end
    id = g_Timer:Start(callback,1,-1)

    UnitTestUpdate(20)
end

--- 测试次数定时器
function UnitTest_01_Time:TestTimerCount()
    local id,callback
    local count = 0
    callback = function()
        count = count + 1
        print("TestTimerLoop " .. count)
        if count >= 10 then
            g_Timer:Stop(id)
        end
    end
    id = g_Timer:Start(callback,1,4)

    UnitTestUpdate(20)
end

--- 测试逻辑帧数定时器
function UnitTest_01_Time:TestFrame()
    local function f1(...)
        print("TestFrame f1 ",...)
    end
    g_Timer:StartFrame(f1,2,2)

    local function f2(...)
        print("TestFrame f2 ",...)
    end
    local id = g_Timer:StartFrame(f2,3,0)

    UnitTestUpdate(30)
    g_Timer:Stop(id)
end

--- 测试定时器callback中添加定时器和停止定时器
function UnitTest_01_Time:TestTimerUpdateAddStop()
    local id,callback
    local count = 0
    local id2,callback2
    callback2 = function()
        print("TestTimerUpdateAddStop callback2 id2 ",id2)
    end
    callback = function()
        count = count + 1
        if count == 1 then
            id2 = g_Timer:Start(callback2,1,4)
        elseif count == 3 then
            g_Timer:Stop(id2)
        end
        if id2 then
            print("TestTimerUpdateAddStop callback id2 ",id2,g_Timer:IsFinish(id2))
        end
    end
    id = g_Timer:Start(callback,1,4)

    UnitTestUpdate(20)
end

UnitTest_01_Time.Run()