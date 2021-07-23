local skynet =  require("skynet")

skynet.start(function ( )

   local msg , sz = skynet.pack("aaa",111,true)
   local arg1,arg2,arg3 = skynet.unpack(msg,sz)
   skynet.error(arg1,arg2,arg3)

   local argaaaa = {skynet.unpack(msg,sz)}

   for key,v in pairs(argaaaa) do
     skynet.error("arg",key,":",v)

   end 

   skynet.trash(msg,sz)



end)