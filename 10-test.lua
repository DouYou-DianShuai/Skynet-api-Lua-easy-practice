local skynet = require("skynet")
require "skynet.manager"
local harbor = require("skynet.harbor")

skynet.start(function()

    local handle = skynet.newservice("1-test")
    skynet.error("我们1-test服务地址",skynet.address(handle))

    skynet.name(".Bendi",handle)
    skynet.name("Quanjv",handle)


    handle = skynet.localname(".Bendi")
    skynet.error("local通过本地别名获得的","我们1-test服务地址",skynet.address(handle))

    handle = skynet.localname("Quanjv")
    skynet.error("local通过全局别名获得的","我们1-test服务地址",skynet.address(handle))

    handle = harbor.queryname(".Bendi")
    skynet.error("query通过本地别名获得的","我们1-test服务地址",skynet.address(handle))

    handle = harbor.queryname("Quanjv")
    skynet.error("query通过全局别名获得的","我们1-test服务地址",skynet.address(handle))

    skynet.kill(handle)

    handle = skynet.localname(".Bendi")
    skynet.error("local通过本地别名获得的","我们1-test服务地址",skynet.address(handle))

    handle = skynet.localname("Quanjv")
    skynet.error("local通过全局别名获得的","我们1-test服务地址",skynet.address(handle))

    handle = harbor.queryname(".Bendi")
    skynet.error("query通过本地别名获得的","我们1-test服务地址",skynet.address(handle))

    handle = harbor.queryname("Quanjv")
    skynet.error("query通过全局别名获得的","我们1-test服务地址",skynet.address(handle))

    local h2 = skynet.newservice("1-test")
    skynet.error("我们1-test服务地址",skynet.address(h2))

    skynet.name(".Bendi",h2)
    h2 = harbor.queryname(".Bendi")
    skynet.error("query通过本地别名获得的","我们1-test服务地址",skynet.address(h2))

    skynet.name("Quanjv",h2)
    h2 = harbor.queryname("Quanjv")
    skynet.error("query通过全局别名获得的","我们1-test服务地址",skynet.address(h2))

    
end)