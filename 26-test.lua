local skynet = require("skynet")
require("skynet.manager")

skynet.register_protocol({--注册system消息
name = "system",
id = skynet.PTYPE_SYSTEM,
-- pack = skynet.pack,
unpack = skynet.unpack, --unpack必须指定一下，接收到消息后会自动使用unpack解析
})

skynet.start(function()

    skynet.dispatch("system",function(se,add,...)
    
        -- skynet.ret(skynet.pack("aaaaaaaaaaa"))
        skynet.retpack("aaaaaaaa")
    
    end)

    skynet.register(".test1")



end)