local skynet = require("skynet")
local socket = require("skynet.socket")

function connect(cID,addr)
    socket.start(cID)
    while true do 

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

end

skynet.start(function()

    lID = socket.listen("0.0.0.0",8900)


    socket.start(lID,accept)

end)