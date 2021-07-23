local skynet = require("skynet")
local socket = require("skynet.socket")
-- function callback(id,size)
--     skynet.error(id,"  写缓冲区过载:",size)
-- end

function connect(cID,addr)
    -- socket.close_fd(cID)
    socket.start(cID)
    -- socket.warning(cID,callback)
    -- skynet.timeout(200,function()  socket.close(cID) end)
    -- skynet.timeout(200,function()  socket.shutdown(cID) end)
    while true do 
        -- skynet.yield()
        -- socket.block(cID)
        -- skynet.error("哈哈哈哈哈哈阿哈哈哈哈哈哈")
        -- local str = socket.read(cID,1)
        str = "aaa"
        if str then
            -- skynet.error("read:",str)
            -- socket.write(cID,string.upper(str))
            -- socket.write(cID,string.upper(str))
            -- socket.write(cID,string.upper(str))
            -- socket.write(cID,string.upper(str))
            -- socket.write(cID,string.upper(str))
            -- socket.write(cID,string.upper(str))
            -- socket.write(cID,string.upper(str))
            -- socket.write(cID,string.upper(str))
            -- socket.write(cID,string.upper(str))
            -- socket.write(cID,string.upper(str))
            -- socket.write(cID,string.upper(str))
            -- socket.write(cID,string.upper(str))
            -- socket.write(cID,string.upper(str))
            -- socket.write(cID,string.upper(str))
            -- socket.write(cID,string.upper(str))
            -- socket.write(cID,string.upper(str))
            -- socket.write(cID,string.upper(str))
            -- socket.write(cID,string.upper(str))
            -- socket.write(cID,string.upper(str))
            -- socket.write(cID,string.upper(str))
            -- socket.write(cID,string.upper(str))
            -- socket.write(cID,string.upper(str))
            -- socket.write(cID,string.upper(str))
            -- socket.write(cID,string.upper(str))
            -- socket.write(cID,string.upper(str))
            -- socket.write(cID,string.upper(str))
            -- socket.write(cID,string.upper(str))
            -- socket.write(cID,string.upper(str))
            -- socket.write(cID,string.upper(str))
            -- socket.write(cID,string.upper(str))
            -- socket.write(cID,string.upper(str))
            -- socket.write(cID,string.upper(str))
        else
            -- socket.close(cID)
            skynet.error("客户端",addr,"已断开连接")
            skynet.error("str",str)
            return
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