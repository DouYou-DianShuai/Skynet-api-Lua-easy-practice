local skynet = require "skynet"
local cos = {}

function task1()
    skynet.error("task1")
    skynet.error("wait")
    skynet.wait(coroutine.running())
    skynet.error("end task1")
end 

function task2()
    skynet.error("task2")
    skynet.error("waitup")
    skynet.wakeup(cos[1])
    
    skynet.error("up")
    skynet.error("up")
    skynet.error("up")
    skynet.error("up")
    skynet.error("up")
    skynet.error("up")
    skynet.error("up")
end

skynet.start(function()
    cos[1] = skynet.fork(task1)
    cos[2] = skynet.fork(task2)

end)