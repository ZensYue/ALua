--------------------------------------------------------------------------------
--      Copyright (c) 2022 , ZensYue ZensYue@163.com
--      All rights reserved.
--      Use, modification and distribution are subject to the "MIT License"
--------------------------------------------------------------------------------

-- 全局方法扩展


function handler_c(fn,obj,param)
    assert(fn ~= nil)
    return function(...)
        if param then
            fn(obj,param,...)
        else
            fn(obj,...)
        end
    end
end

function handler_s(obj,name,param)
    assert(obj[name] ~= nil)
    return function(...)
        if param then
            obj[name](obj,param,...)
        else
            obj[name](obj,...)
        end
    end
end