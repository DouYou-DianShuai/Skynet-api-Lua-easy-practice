local skynet = require("skynet")
local mc = require("skynet.multicast")
local   Id = ...
Id = tonumber(Id)

function read(channel,source,msg,i,...)
    skynet.error("channel:",channel,"source:",skynet.address(source),"msg:",msg,i)
end

skynet.start(function ( )
    c = mc.new({
        channel =  Id,
        dispatch = read,
    })
    c:subscribe()
    skynet.timeout(5000,function() c:unsubscribe()  end)
    skynet.timeout(6000,function() skynet.exit()  end)
    
end)