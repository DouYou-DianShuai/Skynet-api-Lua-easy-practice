local skynet = require("skynet")

function task1()

    skynet.error("task1",coroutine.running())
    skynet.sleep(100)
    error("sadfasd")
    skynet.error("end task1")

end

function task2()

    skynet.error("task2",coroutine.running())

    skynet.sleep(500)
    skynet.error("end task2")
    skynet.timeout(100,task2)
end

skynet.start(function()

    skynet.error("start",coroutine.running())
    skynet.fork(function()
        print(xpcall(task1,function() print(debug.debug(),"Error:这里有错误",debug.traceback())end))
    end)
    skynet.fork(task2)
    skynet.error("end start")



end)



