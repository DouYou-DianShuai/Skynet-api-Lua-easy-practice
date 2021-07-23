local skynet = require("skynet")
local socket = require("skynet.socket")

function send(cID)
    i = 0
    while true do
        i = i+1
        skynet.error("write"..i.."\n")
        socket.write(cID,"das")
        local str = socket.read(cID)
        skynet.error("read:",str)

        skynet.sleep(10)
    end

end
-- function read(cID)
--     while true do
--         local str = socket.read(cID)
--         skynet.error("read:",str)
--         skynet.sleep(10)
--     end

-- end

skynet.start(function()

    cID = socket.open("127.0.0.1",8900)

    skynet.fork(send,cID)
    -- skynet.fork(read,cID)

end)