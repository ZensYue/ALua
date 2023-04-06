--------------------------------------------------------------------------------
--      Copyright (c) 2022 , ZensYue ZensYue@163.com
--      All rights reserved.
--      Use, modification and distribution are subject to the "MIT License"
--------------------------------------------------------------------------------


local timeutil = {}

timeutil.hoursec = 60 * 60
timeutil.daysec = timeutil.hoursec * 24

--- 客户端和服务端相关
-- 中国时区在东八区
timeutil.servertimezone = timeutil.servertimezone or 8
timeutil.localtimezone = timeutil.localtimezone or 0
timeutil.timezonediff = timeutil.timezonediff or 0
timeutil.timediff = timeutil.timediff or 0

--- 返回剩余时间数据
function timeutil.getlasttimedata(seconds)
    local data = {}
    data.sec = seconds
    if data.sec >= timeutil.daysec then
        data.day = math.floor(data.sec / timeutil.daysec)
        data.sec = data.sec % timeutil.daysec
        data.min = 0
        data.hour = 0
    end
    if data.sec >= timeutil.hoursec then
        data.hour = math.floor(data.sec / timeutil.hoursec)
        data.sec = data.sec % timeutil.hoursec
        data.min = 0
    end
    if data.sec >= 60 then
        data.min = math.floor(data.sec / 60)
        data.sec = data.sec % 60
    end
    return data
end

--- 获取指定时间当天的零点时间
function timeutil.getzerotime(time)
    time = time or timeutil.servertime()
    local data = os.date("*t",time)
    data.hour = 0
    data.min = 0
    data.sec = 0
    time = os.time(data)
    return time
end

--- 获取两个时间天数差异相对值
function timeutil.getdiffday(time1,time2)
    if time1 == 0 then
        return 0
    end
    local time_zero_1 = timeutil.getzerotime(time1)
    local time_zero_2 = timeutil.getzerotime(time2)
    if time_zero_1 == nil or time_zero_2 == nil then
        return 0
    end
    return math.floor(math.abs(time_zero_1 - time_zero_2) / timeutil.daysec)
end

-- 获取本地zone时间
function timeutil.getlocaltimezone()
	local now = os.time()
    local localtimezone = os.difftime(now, os.time(os.date("!*t", now)))
    local isdst = os.date("*t", now).isdst
    if isdst then localtimezone = localtimezone + timeutil.hoursec end
    return localtimezone
end

--- 获取本地时区
function timeutil.getlocaltimezoneindex()
    return timeutil.getlocaltimezone()/timeutil.hoursec
end

--- 设置服务端时区
function timeutil.setservertimezone(index)
	timeutil.servertimezone = timeutil.hoursec * index
	timeutil.timezonediff = timeutil.servertimezone - timeutil.localtimezone
end

-- 用服务端和本地算出差异时间
function timeutil.setservertimediff(time)
	timeutil.timediff = time - os.time()
end

-- 获取服务端当前时间
function timeutil.servertime()
	return timeutil.timediff + os.time()
end

-- 获取服务端和本地差异时间
function timeutil.timediff()
	return timeutil.timediff
end

--- notes: 获取服务端固定时分秒时间转化为本地时间
---@param time number
---@param hour number
---@param min number
---@param sec number
function timeutil.serverappoint2local(time,hour,min,sec)
	assert(hour)
	time = time or timeutil.servertime()
	local date = os.date("*t", time)
	date.hour = hour
    date.min = min
    date.sec = sec
    return timeutil.time2local(os.time(date))
end

--- 服务端时间戳转化为本地时间戳
function timeutil.time2local(unixtime)
	unixtime = unixtime or timeutil.servertime()
	if type(unixtime) == "number" then
		return unixtime - timeutil.timezonediff
	else
		-- os.date
		return os.time(unixtime) - timeutil.timezonediff
	end
end

-- 初始化本地时区
timeutil.localtimezone = timeutil.getlocaltimezone()

return timeutil