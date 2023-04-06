
--- 测试动态加载模块
local UnitTest_07_dynamicload = UnitTest.New()

--- 测试一级动态加载
function UnitTest_07_dynamicload:TestLoad()
    UnitTestUpdate(1)
    local path
    path = "common/UnitTest/Test_fiels/Test_dynamicload_item.lua"
    io.writefile(path,"return {[101] = {a = 1,b = 2}}")

    local dynamicloadData = dynamicload("common.UnitTest.Test_fiels.Test_dynamicload_")
    dynamicloadData:set_timefun(function() return g_Timer.m_Time end)
    dynamicloadData:set_checktime(10)
    UnitTestUpdate(1)
    local data = dynamicloadData:get_table()
    print("TestLoad item 101 a = ",data.item[101].a)
    UnitTestUpdate(30)

    dynamicloadData:clear()
end

--- 测试二级动态加载
function UnitTest_07_dynamicload:TestLoadSubTable()
    --- 生成测试案例文件
    local path
    path = "common/UnitTest/Test_fiels/Test_dynamicload_%s_%s.lua"
    local testTab = {"item","scene"}
    local testSubData = {101,102,103}
    for _, name in pairs(testTab) do
        for _, subName in pairs(testSubData) do
            io.writefile(string.format(path,name,subName),string.format("return {a = [[%s_%s]]}",name,subName))
        end
    end

    local dynamicloadData = dynamicload("common.UnitTest.Test_fiels.Test_dynamicload_")
    dynamicloadData:set_timefun(function() return g_Timer.m_Time end)
    dynamicloadData:set_checktime(10)
    UnitTestUpdate(1)
    local data = dynamicloadData:get_table()
    
    for _, name in pairs(testTab) do
        local dynamicloadSubData = dynamicload(dynamicloadData.m_path .. name .. "_")
        dynamicloadSubData:set_timefun(function() return g_Timer.m_Time end)
        dynamicloadSubData:set_checktime(10)
        --- 添加二级动态加载
        dynamicloadData:add_subtable(name,dynamicloadSubData)
    end
    
    print("TestLoad item 101 a = ",data.item[101].a)
    print("TestLoad scene 102 a = ",data.scene[102].a)
    print("TestLoad scene 103 a = ",data.scene[103].a)

    UnitTestUpdate(30)

    dynamicloadData:clear()
end

UnitTest_07_dynamicload.Run()