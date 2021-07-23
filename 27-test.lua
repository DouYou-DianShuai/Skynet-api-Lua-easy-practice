local skynet = require("skynet")
require("skynet.manager")

skynet.register_protocol{--注册system消息
name = "system",
id = skynet.PTYPE_SYSTEM,
pack = skynet.pack,
unpack = skynet.unpack, --unpack必须指定一下，接收到消息后会自动使用unpack解析
}


skynet.start(function()

--   local r = skynet.unpack(skynet.rawcall(".test1","system",skynet.pack("asdf",111)))
    -- skynet.error(r)
    r = skynet.call(".test1","system","asdfasd",1111)

    skynet.error(r)

end)