local floor = math.floor
local abs = math.abs
local sqrt = math.sqrt

function math.round(num)
    return floor(num + 0.5)
end

function math.sign(num)
    if num > 0 then
        num = 1
    elseif num < 0 then
        num = -1
    else
        num = 0
    end

    return num
end

function math.clamp(num, min, max)
    if num < min then
        num = min
    elseif num > max then
        num = max
    end

    return num
end

local clamp = math.clamp

function math.lerp(from, to, t)
    return from + (to - from) * clamp(t, 0, 1)
end

function math.Random(n, m)
    local range = m - n
    return math.random() * range + n
end

-- isnan
function math.isnan(number)
    return not (number == number)
end


local old_randomseed = math.randomseed
math.randomseed = function()
end

function math.newrandomseed()
    local seed = os.time()
    seed = tostring(seed):reverse():sub(1, 7)
    seed = tonumber(seed)
    if not seed then
        seed = os.time()
    end
    if not seed then
        seed = 100
    end
    local status, err = pcall(old_randomseed, seed)
    if not status then
        printerror(err)
    end
    math.random()
    math.random()
    math.random()
    math.random()
end


math.deg2Rad = math.pi / 180
math.rad2Deg = 180 / math.pi
math.epsilon = 1.401298e-45

--- 角度转弧度
function math.angle2radian(angle)
    return angle * math.deg2Rad
end

--- 弧度转角度
function math.radian2angle(radian)
    return radian * math.rad2Deg
end

function math.Fact(num)
	local sum = num
    for i = num, 2, -1 do
		sum = sum*(i-1)
    end
	return sum
end

--- notes: 等差数列的和。p,p+r,p+2r,...,p+(n-1)r;对应index为:1,2,3,...,n
---@param p number 初始价格
---@param n number 起始index
---@param m number 目标index
---@param r number 等差数列的值
---@return number
function math.ArithmeticSequence(p,n,m,r)
    if not r then
        return (2*p+(n-1)*m)*n/2
    end
    if(n==m) then
        return p+(n-1)*r
    end
    if(n>m) then
        return p+(n-1)*r
    end
    local n_v = p+(n-1)*r
    local m_v = p+(m-1)*r
    return (n_v+m_v)*(m-n+1)/2
end
