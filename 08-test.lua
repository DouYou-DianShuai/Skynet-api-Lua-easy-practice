local skynet = require "skynet"

local args = { ... }


skynet.start(function()
    skynet.error(args[1],args[2],#args)

    local us1 = 0
    local us2 = 0
    
    skynet.error("test unique service ")

    skynet.error("1,所有")
    us1 = skynet.uniqueservice(true,args[1])

    skynet.error("2,当前")
    us2 = skynet.uniqueservice(args[2])

    skynet.error("全部节点全局唯一句柄",us1)
    skynet.error("当前节点全局唯一句柄",us2)

end)