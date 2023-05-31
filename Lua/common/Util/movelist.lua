--------------------------------------------------------------------------------
--      Copyright (c) 2023 , ZensYue ZensYue@163.com
--      All rights reserved.
--      Use, modification and distribution are subject to the "MIT License"
--------------------------------------------------------------------------------

--- 数组左移右移n步,支持首尾循环.类似滑动窗口

local movelist = {}
movelist.__index = movelist

---@param list table 数组
---@param step number 移动步长,默认1
---@param loop boolean 是否循环,默认true
function movelist.New(list,step,loop)
    step = step or 1
    loop = loop == nil and true or loop
    local len = #list
    local page = step == 0 and len or math.ceil(len/step)
	local t = {list = list,start_p = 1,last_step = nil,step = step,loop = loop,page = page,pageindex = 1,lenght = len}
	return setmetatable(t, movelist)
end

--- 设置移动步长 不设置默认是1
function movelist:setstep(step)
    self.step = step
end

--- 设置移动起始index 不设置默认是1
function movelist:setstartpoint(index)
    self.start_p = index
    self:legal()
end

--- 判断是否越界
function movelist:legal()
    if self.start_p == 0 then
        self.start_p = self.lenght
    elseif self.start_p > self.lenght or self.start_p < 0 then
        self.start_p = self.start_p%self.lenght
    end
end

--- 清理剩余步长 每次新循环之前需要手动调用
function movelist:clearlaststep()
    self.last_step = nil
end

--- 是否能左移
function movelist:isleft()
    return self.start_p >= 1
end

--- 是否能右移
function movelist:isright()
    return self.start_p <= self.lenght
end

--- 返回当前页序号、总页数
function movelist:getpage()
    return self.pageindex,self.page
end

---@private
function movelist:leftmove()
    --- 左移非循环,判断右边是否越界
    if not self.loop then
        self.start_p = self.start_p > self.lenght and self.lenght or self.start_p
    end
    return self:move(-1)
end

---@private
function movelist:rightmove()
    --- 右移非循环,判断左边是否越界
    if not self.loop then
        self.start_p = self.start_p < 1 and 1 or self.start_p
    end
    return self:move(1)
end

---@private
function movelist:move(step)
    if not self.last_step then
        self.last_step = self.step
    end
    if self.last_step == 0 then
        return nil
    end
    local index = self.start_p
    local node = self.list[index]
    if not node then
        return nil
    end
    self.pageindex = math.ceil(index/self.lenght)
    self.start_p = self.start_p + step
    self.last_step = self.last_step - 1
    if self.loop then
        self:legal()
    end
    return index,node
end

--- 左移迭代器 for index,value in movelist_left(_movelist) do end
movelist_left = function(_movelist) 
    return _movelist.leftmove,_movelist
end

--- 右移迭代器 for index,value in movelist_right(_movelist) do end
movelist_right = function(_movelist) 
    return _movelist.rightmove,_movelist
end

return movelist