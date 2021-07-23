local skynet = require("skynet")

require("skynet.manager")

skynet.start(function ( )
    skynet.dispatch("lua",function (sessino,address,msg,id)

        skynet.sleep(math.random(100,500))

        skynet.retpack(msg:upper(),id)
    end)

    skynet.register(".test1")
end)