
local ReddotType = {
    --- 值类型
    ValueType = {
        Bool = 1,
        Number = 2,
    },

    --- 显示类型
    ShowType = {
        --- 普通显示
        Normal = 1,
        --- 登录一次显示
        LoginOnce = 2,
        --- 每天一次显示(未实现)
        DayOnce = 4,
    },
}

return ReddotType