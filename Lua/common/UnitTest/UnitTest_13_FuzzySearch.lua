

local UnitTest_13_FuzzySearch = UnitTest.New()

local FuzzySearch = require "common.Util.FuzzySearch"
function UnitTest_13_FuzzySearch:TestConfig()

    local config = {
        {name = "acf",id = 1},
        {name = "abcd",id = 2},
        {name = "abcf",id = 3},
        {name = "abc",id = 4},
        {name = "efg",id = 5},
    }

    ---@type FuzzySearch
    local fuzzySearch = FuzzySearch.New()
    fuzzySearch:initConfig(config,"name")
    local list = fuzzySearch:find("abc")
    table.print(list)
end

function UnitTest_13_FuzzySearch:TestStringList()
    local list = {
        "abc",
        "efg",
        "abef",
        "acef",
    }

    ---@type FuzzySearch
    local fuzzySearch = FuzzySearch.New()
    fuzzySearch:initStringList(list)
    local list = fuzzySearch:find("abc")
    table.print(list)
end

UnitTest_13_FuzzySearch.Run()