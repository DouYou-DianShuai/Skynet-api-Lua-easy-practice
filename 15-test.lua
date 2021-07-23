local skynet = require "skynet"

function task( )
    skynet.error("task")
    skynet.error("启动时刻的系统时间",skynet.starttime())
    skynet.error("当前时刻的系统时间",skynet.time())
    skynet.error("程序运行时间",skynet.now())
end

skynet.start(function ( )
    skynet.fork(task)
end)