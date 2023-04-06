
--- 测试热重载模块

local UnitTest_06_Reimport = UnitTest.New()


function UnitTest_06_Reimport:TestReimport()
    local modname = "common.UnitTest.Test_fiels.Test_reimport"
    local path = string.gsub(modname,"%.","/") .. ".lua"
    io.writefile(path,"return {a = 1}")
    local t1 = require(modname)
    print("TestReimport before reimport ",t1.a)
    io.writefile(path,"return {a = 2}")
    local t2 = reimport(modname)
    print("TestReimport after reimport ",t1.a)
    print("TestReimport t1 == t2",t1==t2)
    assert(t1.a == 2,"Fail " .. t1.a)
end

UnitTest_06_Reimport.Run()