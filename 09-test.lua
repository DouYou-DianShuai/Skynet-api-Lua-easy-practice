local skynet = require "skynet"

local args = { ... }

skynet.start(function()
    skynet.error(args[1],args[2],#args)

    local us = 0
    
    skynet.error("test unique service ")

    skynet.error("1,所有")
    us = skynet.queryservice(true,args[1])


    skynet.error("全部节点全局唯一句柄",us)

end)