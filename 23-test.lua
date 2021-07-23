local skynet = require("skynet")


function fun( id )
    for i = 1,5 do
        skynet.error("fun"..id)
        skynet.error("fun"..id,"return:",skynet.call(".test1","lua","fun",id))
    end
end

skynet.start(function()


    skynet.fork(fun,1)
    skynet.fork(fun,2)


end)