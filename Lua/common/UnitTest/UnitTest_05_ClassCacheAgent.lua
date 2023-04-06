
--- 测试class缓存

local UnitTest_05_ClassCacheAgent = UnitTest.New()

--- 测试class缓存,当前缓存一个
function UnitTest_05_ClassCacheAgent:TestCache()
    local testclass = Aclass("test1")
    testclass.__cache_count = 1
    classcacheagent(testclass)
    function testclass:ctor(id)
        self.id = id
        print(self.classname,"call __ctor",self.id)
    end

    function testclass:dctor()
        print(self.classname,"call dctor",self.id)
    end

    function testclass:__cache()
        print(self.classname,"call __cache",self.id)
    end
    
    function testclass:__reset(id)
        print(self.classname,"call __reset",self.id,",new id ",id)
    end

    local count = 2
    local list = {}
    local id=0
    for i = 1, count do
        id = id+1
        table.insert(list,testclass.New(id))
    end
    for i = 1, count do
        list[i]:Delete()
    end
    list = nil

    for i = 1, count do
        id = id+1
        testclass.New(id)
    end
end

UnitTest_05_ClassCacheAgent.Run()