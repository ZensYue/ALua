
local movelist = require "common.Util.movelist"
local UnitTest_14_movelist = UnitTest.New()


function UnitTest_14_movelist:TestMoveOnce()
    local tab = {1,2,3,4,5,6,7,8,9,10}
    --- 每次移动3格,不能循环
    local _movelist = movelist.New(tab,3,0)
    --- 右移5次,第5次没有输出,for不会执行
    --- {1,2,3},{4,5,6},{7,8,9},{10},nil

    for i = 1, 5 do
        _movelist:clearlaststep()
        print(string.format("TestMoveOnce ,i = %s , isright = %s",i,_movelist:isright()))
        for key, value in movelist_right(_movelist) do
            print("move right ",key,value)
        end
    end
end

function UnitTest_14_movelist:TestMoveLoop()
    local tab = {1,2,3,4,5,6,7,8,9,10}
    --- 每次移动3格,循环
    local _movelist = movelist.New(tab,3,1)
    --- 右移5次
    --- {1,2,3},{4,5,6},{7,8,9},{10,1,2},{3,4,5}

    for i = 1, 5 do
        _movelist:clearlaststep()
        print(string.format("TestMoveLoop ,i = %s , isright = %s",i,_movelist:isright()))
        for key, value in movelist_right(_movelist) do
            print("move right ",key,value)
        end
    end
end

function UnitTest_14_movelist:TestMovePage()
    local tab = {1,2,3,4,5,6,7,8,9,10}
    
    
    --- 每次移动3格,按页移动
    local _movelist = movelist.New(tab,3,2)

    --- 右移5次,再左移5次
    --- {1,2,3},{4,5,6},{7,8,9},{10},{1,2,3}
    --- {10},{9,8,7},{6,5,4},{3,2,1},{10}

    for i = 1, 5 do
        _movelist:clearlaststep()
        print(string.format("TestMovePage right ,i = %s , isright = %s",i,_movelist:isright()))
        for key, value in movelist_right(_movelist) do
            print("move right ",key,value)
        end
    end


    for i = 1, 5 do
        _movelist:clearlaststep()
        print(string.format("TestMovePage left ,i = %s , isleft = %s",i,_movelist:isleft()))
        for key, value in movelist_left(_movelist) do
            print("move left ",key,value)
        end
    end
end

UnitTest_14_movelist:Run()