local skynet = require "skynet"

require "skynet.manager"

local harbor = require("skynet.harbor")
local key,value = ...


function fun1() 
    skynet.error("test1"," :",dest)
    r = skynet.send(dest,"lua","set",key,value)
    skynet.error(r)

    skynet.error("------------------------")

    r,aaa,bbb = skynet.call(dest,"lua","get",key)
    skynet.error("GET到了:",r,aaa,bbb)

    

end

skynet.start(function()


    dest = harbor.queryname("test1")
    skynet.fork(fun1)

    skynet.error("test31",skynet.self())


    skynet.register(".test31")

end)