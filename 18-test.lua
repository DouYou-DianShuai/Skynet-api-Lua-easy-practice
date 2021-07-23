local skynet = require("skynet")
require "skynet.manager"

function aaa(session,address,...)
    skynet.error("session:",session)
    skynet.error("address:",address)


    local args = {...} 
    for i,v  in pairs(args)  do

        skynet.error("args:"..i..":",v)
    end
    
    return 100,false



end


skynet.start(function ( )

    skynet.dispatch("lua",function(session,address,...)
        
        

        -- skynet.retpack(aaa(session,address,...))
        skynet.ret(skynet.pack(aaa(session,address,...)))
    
    end)

    skynet.register(".test111111")

end)