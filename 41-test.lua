local skynet = require("skynet")
local socket = require("skynet.socket")

function connect(cID,addr)
    -- socket.start(cID)
    while true do 
        skynet.yield()
        local str = socket.read(cID)
        if str then
            skynet.error("read:",str)
            socket.write(cID,string.upper(str))
        else
            socket.close(cID)
            skynet.error("客户端",addr,"已断开连接")
        end
    end

end

function accept(cID,addr)
    skynet.error("客户端",addr,"已连接")
    skynet.fork(connect,cID,addr)
    skynet.timeout(500,function() socket.abandon(cID)  end)
    skynet.timeout(520,function() skynet.newservice("40-test",cID,addr)  end)
end

skynet.start(function()

    lID = socket.listen("0.0.0.0",8900)


    socket.start(lID,accept)

end)