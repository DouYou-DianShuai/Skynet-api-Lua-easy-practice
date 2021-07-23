local skynet = require("skynet")
local socket = require("skynet.socket")

function connect(cID,addr)
    socket.start(cID)
    while true do 

        local str = socket.readline(cID)
        if str then
            skynet.error("read:",str)
            skynet.sleep(100)
            socket.write(cID,string.upper(str).."\n")
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

cID,addr = ...
cID = tonumber(cID)

skynet.start(function()

    skynet.fork(accept,cID,addr)


end)