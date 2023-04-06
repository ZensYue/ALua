---@class SubscribeType
local SubscribeType = {
    --- 普通订阅 当前值 默认大于等于
    NORMAL = 0, 
    --- 增量订阅 差值 默认大于等于
    INCREMENT = 1,
    --- 小于等于.用 | 添加
    LessThan = 2,
    --- 增量订阅 差值 小于等于
    LessThanINCREMENT = 3,
    --- 等于
    Equal = 4,

    --- 多组 and
    GROUP_AND = 0,
    --- 多组 OR
    GROUP_OR = 1,
}

return SubscribeType