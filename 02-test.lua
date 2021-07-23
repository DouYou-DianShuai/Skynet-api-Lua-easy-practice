local skynet = require "skynet"


    skynet.start(function()
    
    local name = skynet.getenv("myname")
    local age = skynet.getenv("myage")

    skynet.error("My name is ",name ,",",age,"years old.") 

    skynet.setenv("myname","aaaaa")
    skynet.setenv("myage","50")

 --   skynet.setenv("mynewname","aaaaaaa")
 --   skynet.setenv("mynewage","60")

    name = skynet.getenv("myname")
    age = skynet.getenv("myage")


    skynet.error("My name is ",name ,",",age,"years old.") 

end)
