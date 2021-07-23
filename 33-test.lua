local skynet = require("skynet")
local mc = require("skynet.multicast")

function task()

    i = 0
    while(i<100) do
    skynet.sleep(500)
    channel:publish("aaa",i)
    i = i+1
    end

    channel:delete()
    skynet.exit()
end


skynet.start(function ( )
    -- 创建一个频道，成功创建后，channel.channel 是这个频道的 id 。
    channel = mc.new()
    skynet.error("Id:",channel.channel)
    skynet.fork(task)
end)