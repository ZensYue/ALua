--- 测试Table扩展

local UnitTest_08_Table = UnitTest.New()

--- 只读表
function UnitTest_08_Table:TestReadOnly()
    local t = {
        a1 = {b1 = {c1 = 1}},
        a2 = {b2 = {c2 = 2}},
    }

    t = table.readOnly(t)

    t.a1.b1.c1 = 2
end

--- 脏表
function UnitTest_08_Table:TestDirty()
    local tab = {
        a = { b = 1},
        [1] = 1,
        [2] = 2,
        [3] = 3,
        [4] = 4,
    }
    local t = table.dirty(tab)

    t.a.b = 2
    print("TestDirty ",t.__dirty)
    t.__refresh()

    t.a2 = 2
    print("TestDirty ",t.__dirty)
    t.__refresh()

    t.a = {b=2}
    print("TestDirty ",t.__dirty)
    t.__refresh()

    print(table.dump(t,"t"))
    print(table.dump(t.a,"t.a"))
    print(table.dump(t.__data(),"t.__data()"))
end

--- 多条件排序
function  UnitTest_08_Table:TestSort()
    local t = {
        {lv = 1,order = 1,id=1},
        {lv = 1,order = 2,id=2},
        {lv = 2,order = 1,id=3},
        {lv = 2,order = 2,id=4},
        {lv = 3,order = 1,id=5},
        {lv = 3,order = 1,id=6},
        {lv = 1,order = 6,id=7},
    }
    -- 等级 品质 id 大在前
    -- id 6 5 4 3 7 2 1
    local newt1 = table.sortFunc(t,{"lv","order","id"},false)
    print(table.dump(newt1))

    -- 等级小 品质 id 大在前
    -- 7 2 1 4 3 6 5
    local function f(t1,t2,key)
        local v1 = t1[key]
        local v2 = t2[key]
        if v1 == v2 then
            return nil
        end
        if key == "lv" then
            return v1 < v2
        else
            return v1 > v2
        end
    end
    local newt2 = table.sortFunc(t,{"lv","order","id"},false,f)
    print(table.dump(newt2))

    print("TestSort ",newt1 == newt2)

end

UnitTest_08_Table.Run()