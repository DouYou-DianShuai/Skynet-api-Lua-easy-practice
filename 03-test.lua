local skynet = require "skynet"

skynet.init(function ( )
    skynet.error("服务的初始化")
end)

skynet.start(function()
    skynet.error("服务启动")
end)