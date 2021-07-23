local skynet = require "skynet"
harbor = require("skynet.harbor")

require "skynet.manager"
source = skynet.localname(".test31")


function fun1() 
    skynet.redirect(dest,source,"lua", 0,skynet.pack(65))
end

skynet.start(function()

    dest =  harbor.queryname("test1")

    skynet.fork(fun1)

    skynet.error("test32",skynet.self())


end)