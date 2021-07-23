local skynet = require("skynet")
local socket = require("skynet.socket")



skynet.start(function()

    lID = socket.listen("0.0.0.0",8900)


    socket.start(lID,function(id,addr)
        skynet.error("有一个客户端连接成功")
        skynet.newservice("40-test",id,addr)
        
    end)

end)