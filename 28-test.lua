local skynet = require("skynet")
require "skynet.manager"

skynet.register_protocol{
    name = "system",
    id = skynet.PTYPE_SYSTEM,
    -- pack = 
    unpack =  function (...) return ... end
}

forward_map = {
[skynet.PTYPE_LUA]=skynet.PTYPE_SYSTEM,
[skynet.PTYPE_RESPONSE]=skynet.PTYPE_RESPONSE
}

skynet.forward_type(forward_map ,function()
    skynet.dispatch("system",function(ss,a,...)
        skynet.ret(skynet.rawcall(".test1","lua",...))

    end)
    skynet.register(".test2")

end)
