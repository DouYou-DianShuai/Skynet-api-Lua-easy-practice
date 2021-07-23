local skynet = require "skynet"

function func()
    skynet.error("func",coroutine.running())
    skynet.timeout(500,func)
end

skynet.start(function()

    skynet.error("start", coroutine.running())    

    a = skynet.timeout(500,func)

    skynet.error("aaasdsfasdf",a)


end)
