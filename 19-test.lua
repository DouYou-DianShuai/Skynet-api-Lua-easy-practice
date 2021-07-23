local skynet =require("skynet")
require "skynet.manager"

skynet.start(function ( )
    
    skynet.register(".test2")
    local addr1 = skynet.localname(".test111111")

    r = skynet.send(addr1,"lua",1, "aaa",true)
    -- local r1 , r2 = skynet.call(addr1,"lua",1, "aaa",true)
    -- skynet.error(r1,r2)

    r = skynet.rawsend(addr1,"lua",skynet.pack(2,"bbb",false))
    -- msg , sz = skynet.rawcall(addr1,"lua",skynet.pack(2,"bbb",false))
    -- skynet.error(skynet.unpack(msg ,sz))

    -- msg , sz = skynet.rawcall(addr1,"lua",skynet.pack(2,"bbb",false))
    -- msg , sz = skynet.rawcall(addr1,"lua",skynet.pack(2,"bbb",false))
end)