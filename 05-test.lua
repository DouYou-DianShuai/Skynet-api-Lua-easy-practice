local skynet = require("skynet")


skynet.start(function()
    skynet.error("My new service")
    skynet.newservice("1-test")
    skynet.error("new test service 1")
    skynet.newservice("1-test")
    skynet.error("new test service 2")

end)