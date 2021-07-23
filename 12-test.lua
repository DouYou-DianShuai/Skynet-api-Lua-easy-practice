local skynet = require "skynet"

function func_cb(timeout)

    skynet.error("func_cb",coroutine.running())

    -- skynet.sleep(timeout)
    for num = 1,30 do
        skynet.error("携程挂起",coroutine.running())
        skynet.yield()
        if(num == 30 ) then
            skynet.error(num)
        end
    end
    skynet.error("fun_cb end",coroutine.running())
    


end



skynet.start(function()

    -- skynet.sleep(500);
    skynet.fork(func_cb,500)
    skynet.fork(func_cb,500)

    skynet.error("end",coroutine.running())

end)