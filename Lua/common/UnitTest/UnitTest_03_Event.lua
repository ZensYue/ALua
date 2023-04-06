
--- 测试事件系统

---@type UnitTest
local UnitTest_03_Event = UnitTest.New()

--- 普通事件
function UnitTest_03_Event:Test_Event()
    ---@type Event
    local event = Event.New()
    local evnet_key = "test1"
    local event_id1,event_id2,event_id3,event_ids,callback3
    local function callback1(value)
        print("Test_Event callback1 ",value)

        if event_id3 and value >=3 then
            print("Remove event_id3")
            event:Remove(event_id3)
            event_id3 = nil
        end
    end

    local function callback2(value)
        print("Test_Event callback2 ",value)
        if value == 1 and not event_id3 then
            event_id3 = event:Add(evnet_key,callback3)
        end
    end
    callback3 = function(value)
        print("Test_Event callback3 ",value)
    end
    event_id1 = event:Add(evnet_key,callback1)
    event_id2 = event:Add(evnet_key,callback2)
    event_ids = {}
    event_ids[#event_ids+1] = event_id1
    event_ids[#event_ids+1] = event_id2

    event:Brocast(evnet_key,1)
    event:Brocast(evnet_key,2)
    event:Brocast(evnet_key,3)
    event:RemoveList(event_ids)
    event:Brocast(evnet_key,4)
end

--- 延迟事件 
function UnitTest_03_Event:Test_TimeEvent()
    UnitTestUpdate(1)
    ---@type Event
    local event = Event.New()
    local evnet_key = "test1"

    --- 设置时间事件，2秒内最多刷新一次
    event:SetTimeInfo(evnet_key,2)

    local event_id1,event_id2
    local function callback1(...)
        print("Test_TimeEvent callback1 ",g_Timer:GetTime())
    end

    local function callback2(...)
        print("Test_TimeEvent callback2 ",g_Timer:GetTime())
    end
    event_id1 = event:Add(evnet_key,callback1)
    event_id2 = event:Add(evnet_key,callback2)

    event:Brocast(evnet_key,1)
    event:Brocast(evnet_key,2)
    event:Brocast(evnet_key,3)
    print("Test_TimeEvent Brocast ",g_Timer:GetTime())


    UnitTestUpdate(10)
    print("Test_TimeEvent Brocast CurTime =  ",g_Timer:GetTime())
    event:Brocast(evnet_key,4)

    UnitTestUpdate(10)
end

UnitTest_03_Event.Run()