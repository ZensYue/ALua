

UnitTest = require "common.UnitTest.UnitTest"


local time = 0
function UnitTestUpdate(count)
    for i = 1, count do
        time = time + 1
        g_Timer:update(time,time)
    end
end

require "common.UnitTest.UnitTest_01_Time"
require "common.UnitTest.UnitTest_02_Subscribe"
require "common.UnitTest.UnitTest_03_Event"
require "common.UnitTest.UnitTest_04_Reddot"
require "common.UnitTest.UnitTest_05_ClassCacheAgent"
require "common.UnitTest.UnitTest_06_Reimport"
require "common.UnitTest.UnitTest_07_dynamicload"
require "common.UnitTest.UnitTest_08_Table"
require "common.UnitTest.UnitTest_09_String"
require "common.UnitTest.UnitTest_10_Delegate"
require "common.UnitTest.UnitTest_11_Object"
require "common.UnitTest.UnitTest_12_FilterWords"
require "common.UnitTest.UnitTest_13_FuzzySearch"
require "common.UnitTest.UnitTest_14_movelist"