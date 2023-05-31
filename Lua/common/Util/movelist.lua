--------------------------------------------------------------------------------
--      Copyright (c) 2023 , ZensYue ZensYue@163.com
--      All rights reserved.
--      Use, modification and distribution are subject to the "MIT License"
--------------------------------------------------------------------------------

--- 数组左移右移n步,支持首尾循环.类似滑动窗口

---@class movelist
local movelist = {}
movelist.__index = movelist

---@param list table 数组
---@param step number 移动步长,默认1
---@param looptype number 循环类型 0不循环 1循环 2page循环. 
--- 例子{1,2,3},step 2,右移3次,结果如下:
--- 0不循环 {1,2}{3}.
--- 1循环 {1,2}{3,1}{2,3}.
--- 2page循环 {1,2}{3}{1,2}
---@return movelist
function movelist.New(list,step,looptype)
    step = step or 1
    looptype = looptype and looptype or 1
    local len = #list
    local page = step == 0 and len or math.ceil(len/step)
	local t = {list = list,left_p = len,right_p = 1,last_step = nil,step = step,looptype = looptype,page = page,pageindex = 1,lenght = len}
	return setmetatable(t, movelist)
end

--- 设置移动步长 不设置默认是1
function movelist:setstep(step)
    self.step = step
end

--- 设置移动起始index 不设置默认是1
function movelist:setstartpoint(index)
    self.right_p = self:legal(index)
    self.left_p = self:legal(self.right_p - 1)
end

--- 判断是否越界
function movelist:legal(index)
    if index == 0 then
        index = self.lenght
        return index,true
    elseif index > self.lenght or index < 0 then
        index = index%self.lenght
        return index,true
    end
    return index,false
end

--- 清理剩余步长 每次新循环之前需要手动调用
function movelist:clearlaststep()
    self.last_step = nil
end

--- 是否能左移
function movelist:isleft()
    return self.left_p >= 1
end

--- 是否能右移
function movelist:isright()
    return self.right_p <= self.lenght
end

--- 返回当前页序号、总页数
function movelist:getpage()
    return self.pageindex,self.page
end

---@private
function movelist:leftmove()
    return self:move(true)
end

---@private
function movelist:rightmove()
    return self:move(false)
end

---@private
function movelist:move(ismoveleft)
    if not self.last_step then
        self.last_step = self.step
        if ismoveleft then
            self.right_p = self:legal(self.left_p + 1)
        else
            self.left_p = self:legal(self.right_p - 1)
        end
    end
    if self.last_step == 0 then
        return nil
    end
    local index = ismoveleft and self.left_p or self.right_p
    local node = self.list[index]
    if not node then
        return nil
    end
    local step = ismoveleft and -1 or 1
    self.pageindex = math.ceil(index/self.lenght)
    self.last_step = self.last_step - 1
    if ismoveleft then
        self.left_p = self.left_p + step
        if self.looptype == 1 then
            self.left_p = self:legal(self.left_p)
        elseif self.looptype == 2 then
            local new_l,islegal = self:legal(self.left_p)
            self.left_p = new_l
            if islegal then
                self.last_step = 0
            end
        end
    else
        self.right_p = self.right_p + step
        if self.looptype == 1 then
            self.left_p = self:legal(self.right_p)
        elseif self.looptype == 2 then
            local new_r,islegal = self:legal(self.right_p)
            self.right_p = new_r
            if islegal then
                self.last_step = 0
            end
        end
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