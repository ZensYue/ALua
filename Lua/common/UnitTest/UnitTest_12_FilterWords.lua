
local UnitTest_12_FilterWords = UnitTest.New()

function UnitTest_12_FilterWords:Test()
    local FilterWords = require "common.Util.FilterWords"
    local words = {
        "hello",
        "hellosss",
    }
    ---@type FilterWords
    local filterWords = FilterWords.New()
    filterWords:createTree(words)

    local testStrs = {
        "helloahellosssaahelloss", -- *****a*****sssaa*****ss
        "hellsssaaahellosa", -- hellsssaaa*****sa
    }
    for key, value in pairs(testStrs) do
        local isSafe = filterWords:isSafe(value)
        local toStr = filterWords:toSafe(value)
        local log = string.format("UnitTest_12_FilterWords word = %s , isSafe = %s , toStr = %s",value,isSafe,toStr)
        print(log)
    end
    
end

UnitTest_12_FilterWords.Run()