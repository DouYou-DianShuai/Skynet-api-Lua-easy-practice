local skynet = require("skynet")

require "skynet.manager"


local sss = {}

local  a = {}

function sss.SET(key,value)

    a[key] = value

end

function sss.GET(key)
    return a[key]
end


skynet.start(function()
    skynet.dispatch("lua",function(s,a,cmd,...)
        skynet.error("来自",a,"的消息")
        cmd = cmd:upper()
        local f = sss[cmd]
        
        if f then
            skynet.retpack(f(...))
        else
            skynet.error(string.format("%s:方法不存在",tostring(cmd)))
        end
    
    end)

    skynet.register("test1")

end)