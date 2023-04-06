
local UnitTest_09_String = UnitTest.New()

function UnitTest_09_String:TestSplit()
    local s = "a,b,c,d"
    local t = string.split(s,",")
    table.dump(t)
end

function UnitTest_09_String:TestAll()
    print("tochinesenumber ",string.tochinesenumber(100101010))

    print("utfStrlen ",string.utfStrlen("你好"))
end

UnitTest_09_String.Run()