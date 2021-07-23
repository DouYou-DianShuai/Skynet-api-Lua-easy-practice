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
        skynet.error("start dispatch",coroutine.running())

        local response = skynet.response()
        skynet.fork(function(s,a,cmd,...)
            skynet.error("fork",coroutine.running())
            cmd = cmd:upper()
            local f = sss[cmd]
            
            if f then
                -- skynet.retpack(f(...))
                a ={ response("st",f(...)) }
                for i = 1,#a do
                    skynet.error("三大发送的法斯蒂芬",a[i])
                end
            else
                skynet.error(string.format("%s:方法不存在",tostring(cmd)))
            end
        end,s,a,cmd,...)
       
    
    end)

    skynet.register(".test1")

end)