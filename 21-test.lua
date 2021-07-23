local skynet = require "skynet"

local key,value = ...


function fun1() 
    r = skynet.send(".test1","lua","set",key,value)
    skynet.error(r)

    skynet.error("------------------------")

    r,aaa,bbb = skynet.call(".test1","lua","get",key)
    skynet.error("GET到了:",r,aaa,bbb)

    
    skynet.exit()

end

skynet.start(function()


    skynet.fork(fun1)

end)