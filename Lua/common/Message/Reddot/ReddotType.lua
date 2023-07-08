
---@class ReddotCacheInfo
---@field key string
---@field showType number
---@field time number


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
        --- 每天一次显示
        DayOnce = 4,
        --- 机器只显示一次
        PlatformOnce = 8,
    },
}

return ReddotType