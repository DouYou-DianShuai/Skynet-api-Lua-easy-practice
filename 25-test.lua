local skynet = require("skynet")

require "skynet.manager"
local   queue = require "skynet.queue"
local   cs  = queue()

local sss = {}

local  a = {}

function sss.SET(key,value)

    a[key] = value

end

function sss.GET(key)
    skynet.sleep(500)
    return a[key]
end


skynet.start(function()
    skynet.dispatch("lua",function(s,a,cmd,...)
    
        cmd = cmd:upper()
        local f = sss[cmd]
        
        if f then
            skynet.retpack(cs(f,...))
        else
            skynet.error(string.format("%s:方法不存在",tostring(cmd)))
        end
    
    end)

    skynet.register(".test1")

end)