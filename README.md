# Skynet-api-Lua-easy-practice
学习了lua语言和skynet的使用

上个月学习的，当时练习的案例也放上来，方便复习。

当时的笔记也大多是借鉴，仅仅方便自己看。只是一些简单的，方便自己入门，往后的没有记，到时候直接看教程使用

###### 本笔记参考CSDN平台 吓人的猿 老师的博客内容,链接https://blog.csdn.net/qq769651718/article/details/79432809
###### 感谢前辈留下的博客给后来初学者参考学习
## 1-介绍
##### skynet介绍
Skynet是一个基于C和Lua的开源服务端并发框架，这个框架是单进程多线程Actor模型。

##### Actor模型特点
* 系统以actor为单位持有资源，包括cpu，内存，对象
* actor与actor之间不共享资源，只能通过邮箱互发消息
* 不同的actor处理消息是并发的
* 对于每1个actor可能在调度状态和非调度状态，调度状态下依次处理每个消息
##### skynet调度模型
* 线程池+服务队列
```
--线程池:若干个工作者线程，一个定时器线程，一个Socket线程  组成
--服务队列:若干个 actor(消息队列) 组成
--工作方式：工作者线程来调用 服务队列中的 消息队列
```
##### Actor模型介绍
* Actor模型内部的状态由它自己维护即它内部数据只能由它自己修改(通过消息传递来进行状态修改)--隔离性强,所以使用Actor模型进行并发编程可以很好地避免一些多线程编程时的资源共用问题。
* Actor由状态(state)，行为（Behavior)和邮箱(mailBox)三部分组成
```markdown
1-**状态(state)**:Actor中的状态指的是变量信息，状态由Actor自己管理，避免了并发环境下的锁和内存原子性问题
2-**行为(Behavior)**:行为指定的是Actor中的计算逻辑，通过Actor接收到消息来改变Actor的状态
3-**邮箱(mailBox)**:邮箱是Actor和Actor之间的通信桥梁，邮箱内部通过FIFO消息队列来存储发送方Actor消息，接收方Actor从邮箱队列中获取消息
```
Actor的基础就是消息传递，skynet中每个服务就是一个LUA虚拟机，就是一个Actor。
##### Actor模型好处
* **事件模型驱动**: Actor之间的通信是异步的，即使Actor在发送消息后也无需阻塞或者等待就能够处理其他事情。
* **强隔离性**: Actor中的方法不能由外部直接调用，所有的一切都通过消息传递进行的，从而避免了Actor之间的数据共享，想要观察到另一个Actor的状态变化只能通过消息传递进行询问。
* **位置透明**: 无论Actor地址是在本地还是在远程机上对于代码来说都是一样的。
* **轻量性**: Actor是非常轻量的计算单机，只需少量内存就能达到高并发。
## 2-如何安装搭建Skynet
* 安装git代码管理工具
```shell
$ sudo apt-get update
$ sudo apt-get install git
```
注意：如果安装失败，请先安装一下支持库
```shell
$ sudo apt-get install build-essential libssl-dev libcurl4-gnutls-dev libexpat1-dev gettext unzip
```
* 从github上面下载skynet的源代码。skynet的代码保存在github上面,用git拷贝下载
```shell
$ git clone https://github.com/cloudwu/skynet.git
```
* skynet代码目录结构
```shell
3rd            #第三方支持库，包括LUA虚拟机，jmalloc等
lualib         #lua语言封装的常用库，包括http、md5
lualib-src     #将c语言实现的插件捆绑成lua库，例如数据库驱动、bson、加密算法等
service        #使用lua写的Skynet的服务模块
service-src    #使用C写的Skynet的服务模块
skynet-src     #skynet核心代码目录
test           #使用lua写的一些测试代码
examples       #示例代码
Makefile       #编译规则文件，用于编译
platform.mk    #编译与平台相关的设置
```
* 编译与运行skynet
```shell
$ cd skynet    #今后我们所有的工作都在这个目录中进行
$ make linux
```
```shell
#如果报错： 
./autogen.sh: 5: ./autogen.sh: autoconf: not found
#安装autoconf
$ sudo apt-get install autoconf

#如果这个也报错
$ sudo apt-get install texlive-plain-generic
#然后继续安装autoconf
```
```shell
#如果报错：
lua.c:83:31: fatal error: readline/readline.h: No such file or directory
#安装libreadline-dev
$ sudo apt-get install libreadline-dev
```
```shell
#编译成功出现以下提示
make[1]: Leaving directory '/home/ubuntu/workspace/skynet'
#并且在目录里出现一个可执行文件skynet
```
```shell
 #启动一个skynet服务节点
 $ ./skynet examples/config 
```
* 运行客户端
```
我们要运行的客户端是example/client.lua这个lua脚本文件，那么首先你要有一个lua虚拟机程序。
```
```shell
#编译lua虚拟机
#打开另一个终端，开始编译虚拟机
$ cd ./3rd/lua
$ make linux
#编译成功则会在当前路径上面看到一个可执行文件lua
```
```shell
#运行客户端
$ cd ../../     #回到skynet目录
#运行client.lua这个脚本
$ ./3rd/lua/lua examples/client.lua
```
## 3-构建服务的基础API
```lua
local skynet = require "skynet" 
​
--conf配置信息已经写入到注册表中，通过该函数获取注册表的变量值
skynet.getenv(varName) 。
​
--设置注册表信息，varValue一般是number或string，但是不能设置已经存在的varname
skynet.setenv(varName, varValue) 
​
--打印函数
skynet.error(...)
​
--用 func 函数启动开始服务，并将消息处理函数注册到 C 层，让该服务可以工作。
skynet.start(func) 
​
--若服务尚未初始化完成，则注册一个函数等服务初始化阶段再执行；若服务已经初始化完成，则立刻运行该函数。
skynet.init(func) 
​
--结束当前服务
skynet.exit() 
​
--获取当前服务的句柄handler
skynet.self()
​
--将handle转换成字符串
skynet.address(handler)
​
--退出skynet进程
require "skynet.manager"   --除了需要引入skynet包以外还要再引入skynet.manager包。
skynet.abort()
​
--强制杀死其他服务
skynet.kill(address) --可以用来强制关闭别的服务。但强烈不推荐这样做。因为对象会在任意一条消息处理完毕后，毫无征兆的退出。所以推荐的做法是，发送一条消息，让对方自己善后以及调用 skynet.exit 。注：skynet.kill(skynet.self()) 不完全等价于 skynet.exit() ，后者更安全。
```
#### 3.1-初步使用-编写一个1-test.lua
* 编写一个最简单的服务(找一个你认为和是的文件夹建立这个1-test.lua文件,并编写代码)
```lua
--调用模块skynet，并给其取别名为skynet
local skynet = require "skynet"

--调用skynet.start接口，并定义为传入回调函数，将消息处理注册到C层，让该函数可以工作。
skynet.start(function()
    skynet.error("第一个程序-为熟悉skynet")
end)
```
#### 3.2-通过skynet启动我们编写的1-test.lua
* 我们复制一份exmaple/config文件，命名为1-test，打开1-test并将其中的start的值为1-test，表示启动1-test.lua
```lua
include "config.path"

-- preload = "./examples/preload.lua"	-- run preload.lua before every lua service run
thread = 8
logger = nil
logpath = "."
harbor = 1
address = "127.0.0.1:2526"
master = "127.0.0.1:2013"
start = "1-test"	-- main script      --修改这个位置
bootstrap = "snlua bootstrap"	-- The service for bootstrap
standalone = "0.0.0.0:2013"
-- snax_interface_g = "snax_g"
cpath = root.."cservice/?.so"
-- daemon = "./skynet.pid"
```
* 通过skynet来运行1-test.lua
```shell
$ ./skynet examples/1-test
```
注意：千万不要在skynet可执行程序以外的地方执行skynet
* 你会发现并没有运行成功， 以上出现找不到logger.so的情况，其实不仅仅是这个模块找不到，所有的模块都找不到了，因为在1-test中引用的路径文件config.path中，所有的模块路劲的引入全部依靠着基于我们当前位置的相对路径。一旦执行skynet程序的位置不一样了，相对路径也会不一样。
```lua
root = "./"      --由于这个位置是相对路径，因此有了上述话语
luaservice = root.."service/?.lua;"..root.."test/?.lua;"..root.."examples/?.lua;"..root.."test/?/init.lua"
lualoader = root .. "lualib/loader.lua"
lua_path = root.."lualib/?.lua;"..root.."lualib/?/init.lua"
lua_cpath = root .. "luaclib/?.so"
snax = root.."examples/?.lua;"..root.."test/?.lua"
```
* 我们可以基于这个相对路径添加自己的lua文件路径,打开config.path添加
```lua
root = "./"
--我们在下面这行添加自己的lua文件路径，注意格式保持一致
luaservice = root.."service/?.lua;"..root.."test/?.lua;"..root.."examples/?.lua;"..root.."test/?/init.lua;"..root.."../projects/6.syknet学习/?.lua"
lualoader = root .. "lualib/loader.lua"
lua_path = root.."lualib/?.lua;"..root.."lualib/?/init.lua"
lua_cpath = root .. "luaclib/?.so"
snax = root.."examples/?.lua;"..root.."test/?.lua"
```
* 运行           
```shell
$ ./skynet examples/1-test 
```
**注意**:我们的1-test文件所在目录，一定要有config.path文件
###### 我的1-test是创建examples中的，这里有config.path文件，如果你的在别的位置，就复制一份过去
* 最终运行成功
```shell
[:01000002] LAUNCH snlua bootstrap
[:01000003] LAUNCH snlua launcher
[:01000004] LAUNCH snlua cmaster
[:01000004] master listen socket 0.0.0.0:2013
[:01000005] LAUNCH snlua cslave
[:01000005] slave connect to master 127.0.0.1:2013
[:01000004] connect from 127.0.0.1:39276 4
[:01000006] LAUNCH harbor 1 16777221
[:01000004] Harbor 1 (fd=4) report 127.0.0.1:2526
[:01000005] Waiting for 0 harbors
[:01000005] Shakehand ready
[:01000007] LAUNCH snlua datacenterd
[:01000008] LAUNCH snlua service_mgr
[:01000009] LAUNCH snlua 1-test
[:01000009] 第一个程序-为熟悉skynet       
[:01000002] KILL self
```
#### 3.3-介绍下另一种启动服务的方式
 * 另一种方式启动想要的服务，可以在main.lua运行后，在console直接输入需要启动的服务名称

     --也就是先启动main.lua(大家应给记得我们的config就是启动的main.lua)
 ```shell
$ ./skynet examples/config
 ```
 **注意**：我们的config.path路径中要有你的lua文件所在的目录。
 * 在启动的main服务中，直接输入你要启动的lua文件的文件名，回车。(如1-test）
  
    --运行结果
```shell
[:01000002] LAUNCH snlua bootstrap
[:01000003] LAUNCH snlua launcher
[:01000004] LAUNCH snlua cmaster
[:01000004] master listen socket 0.0.0.0:2013
[:01000005] LAUNCH snlua cslave
[:01000005] slave connect to master 127.0.0.1:2013
[:01000004] connect from 127.0.0.1:39434 4
[:01000006] LAUNCH harbor 1 16777221
[:01000004] Harbor 1 (fd=4) report 127.0.0.1:2526
[:01000005] Waiting for 0 harbors
[:01000005] Shakehand ready
[:01000007] LAUNCH snlua datacenterd
[:01000008] LAUNCH snlua service_mgr
[:01000009] LAUNCH snlua main
[:01000009] Server start
[:0100000a] LAUNCH snlua protoloader
[:0100000b] LAUNCH snlua console
[:0100000c] LAUNCH snlua debug_console 8000
[:0100000c] Start debug console at 127.0.0.1:8000
[:0100000d] LAUNCH snlua simpledb
[:0100000e] LAUNCH snlua watchdog
[:0100000f] LAUNCH snlua gate
[:0100000f] Listen on 0.0.0.0:8888
[:01000009] Watchdog listen on 8888
[:01000009] KILL self
[:01000002] KILL self
1-test
[:01000010] LAUNCH snlua 1-test
[:01000010] 第一个程序-为熟悉skynet
```
#### 3.4-环境变量
* 预先加载的环境变量是在config中配置的，加载完成后，所有的service都能去获取这些变量。
* 也可以去设置环境变量，但是不能修改已经存在的环境变量。
* 环境变量设置完成后，当前节点上的所有服务都能访问的到。
* 环境变量设置完成后，即使是服务退出了，环境变量依然存在，所以不要滥用环境变量。
* ***接下来我们操作一下***
```markdown
**首先，我们在配置文件config中自定义两个环境变量**
```
```lua
myname = "俺斗会耍游戏"
myage = 24
```
```markdown
**然后，我们建立第二个lua的测试文件 2-test.lua 并写下如下代码**
```lua
local skynet = require "skynet" 

skynet.start(function()
    --获取config中已经配置的环境变量myname和myage的值，成功返回其值，如果该环境变量不存在返回nil
    local name = skynet.getenv("myname")
    local age = skynet.getenv("myage")  
    skynet.error("My name is", name, ",", age, "years old.")


    --不要尝试修改已经存在的变量值，会报错
    --skynet.setenv("myname", "coder")  
    --skynet.setenv("myage", 21)

    --设置环境新的环境变量，本接口无法修改已经存在的环境变量
    skynet.setenv("mynewname", "coder") --设置一个新的变量
    skynet.setenv("mynewage", 21)
    
    name = skynet.getenv("mynewname")   
    age = skynet.getenv("mynewage") 
    skynet.error("My new name is", name, ",", age, "years old soon.")
    skynet.exit()
end)
```
```markdown
**最后我们运行一下代码(两种启动服务方式都可以,这里是第二种方式运行后的结果)**
```
```shell
[:01000002] LAUNCH snlua bootstrap
[:01000003] LAUNCH snlua launcher
[:01000004] LAUNCH snlua cmaster
[:01000004] master listen socket 0.0.0.0:2013
[:01000005] LAUNCH snlua cslave
[:01000005] slave connect to master 127.0.0.1:2013
[:01000004] connect from 127.0.0.1:40028 4
[:01000006] LAUNCH harbor 1 16777221
[:01000004] Harbor 1 (fd=4) report 127.0.0.1:2526
[:01000005] Waiting for 0 harbors
[:01000005] Shakehand ready
[:01000007] LAUNCH snlua datacenterd
[:01000008] LAUNCH snlua service_mgr
[:01000009] LAUNCH snlua main
[:01000009] Server start
[:0100000a] LAUNCH snlua protoloader
[:0100000b] LAUNCH snlua console
[:0100000c] LAUNCH snlua debug_console 8000
[:0100000c] Start debug console at 127.0.0.1:8000
[:0100000d] LAUNCH snlua simpledb
[:0100000e] LAUNCH snlua watchdog
[:0100000f] LAUNCH snlua gate
[:0100000f] Listen on 0.0.0.0:8888
[:01000009] Watchdog listen on 8888
[:01000009] KILL self
[:01000002] KILL self
2-test
[:01000010] LAUNCH snlua 2-test
[:01000010] My name is 俺斗会耍游戏 , 24 years old.
[:01000010] My new name is coder , 21 years old soon.
[:01000010] KILL self
```
#### 3.5-skynet.init()的使用
* skynet.init()用来注册一个我们启动服务之前需要执行的初始化服务函数。也就是在skynet.start()之前运行。
* ***接下来我们操作一下***
```markdown
**首先，我们创建我们的第三个lua测试文件，3-test.lua并写入如下代码**
```
```lua
local skynet = require "skynet"

skynet.init(function()
    skynet.error("服务初始化")
end)

skynet.start(function()
    skynet.error("服务启动")
end)
```
```markdown
**最后我们运行一下代码(两种启动服务方式都可以,这里是第二种方式运行后的结果)**
```
```shell
[:01000002] LAUNCH snlua bootstrap
[:01000003] LAUNCH snlua launcher
[:01000004] LAUNCH snlua cmaster
[:01000004] master listen socket 0.0.0.0:2013
[:01000005] LAUNCH snlua cslave
[:01000005] slave connect to master 127.0.0.1:2013
[:01000004] connect from 127.0.0.1:40300 4
[:01000006] LAUNCH harbor 1 16777221
[:01000004] Harbor 1 (fd=4) report 127.0.0.1:2526
[:01000005] Waiting for 0 harbors
[:01000005] Shakehand ready
[:01000007] LAUNCH snlua datacenterd
[:01000008] LAUNCH snlua service_mgr
[:01000009] LAUNCH snlua main
[:01000009] Server start
[:0100000a] LAUNCH snlua protoloader
[:0100000b] LAUNCH snlua console
[:0100000c] LAUNCH snlua debug_console 8000
[:0100000c] Start debug console at 127.0.0.1:8000
[:0100000d] LAUNCH snlua simpledb
[:0100000e] LAUNCH snlua watchdog
[:0100000f] LAUNCH snlua gate
[:0100000f] Listen on 0.0.0.0:8888
[:01000009] Watchdog listen on 8888
[:01000009] KILL self
[:01000002] KILL self
3-test
[:01000010] LAUNCH snlua 3-test
[:01000010] 服务初始化
[:01000010] 服务启动
```
## 4-服务类型
skynet中的服务分为普通服务与全局唯一服务。第3节启动方式就是一个普通服务，而全局唯一服务顾名思义就是在skynet中只能生成一个服务实例。
#### 4.1-普通服务
* 每调用一次创建接口就会创建出一个对应的服务实例，可以同时创建成千上万个，用唯一的id来区分每个服务实例。使用的创建接口是:
```lua
--用于启动一个新的lua服务，luaServerName是脚本的名字（不用写.lua后缀)
--只有被启动的脚本的start函数返回后，这个API才会返回启动的服务的地址，这是一个阻塞API
--如果被启动的脚本在初始化环节抛出异常，skynet.newservice也会执行失败
--如果被启动脚本的start函数是一个永不结束的循环，那么newservice也会被永远阻塞住
skynet.newservice(luaServerName,...)
```
* 让我们编写一个4-test.lua服务，并从中启动一个1-test.lua服务
```lua
local skynet = require "skynet"

skynet.start(function()
    skynet.error("My new service")
    skynet.newservice("1-test")    --这里启动1-test
    skynet.error("new test service")
end)
```
*运行结果如下*
```bash
[:01000002] LAUNCH snlua bootstrap
[:01000003] LAUNCH snlua launcher
[:01000004] LAUNCH snlua cmaster
[:01000004] master listen socket 0.0.0.0:2013
[:01000005] LAUNCH snlua cslave
[:01000005] slave connect to master 127.0.0.1:2013
[:01000004] connect from 127.0.0.1:36870 4
[:01000006] LAUNCH harbor 1 16777221
[:01000004] Harbor 1 (fd=4) report 127.0.0.1:2526
[:01000005] Waiting for 0 harbors
[:01000005] Shakehand ready
[:01000007] LAUNCH snlua datacenterd
[:01000008] LAUNCH snlua service_mgr
[:01000009] LAUNCH snlua main
[:01000009] Server start
[:0100000a] LAUNCH snlua protoloader
[:0100000b] LAUNCH snlua console
[:0100000c] LAUNCH snlua debug_console 8000
[:0100000c] Start debug console at 127.0.0.1:8000
[:0100000d] LAUNCH snlua simpledb
[:0100000e] LAUNCH snlua watchdog
[:0100000f] LAUNCH snlua gate
[:0100000f] Listen on 0.0.0.0:8888
[:01000009] Watchdog listen on 8888
[:01000009] KILL self
[:01000002] KILL self
4-test
[:01000010] LAUNCH snlua 4-test
[:01000010] My new service              
[:01000012] LAUNCH snlua 1-test
[:01000012] 第一个程序-为熟悉skynet
[:01000010] new test service
```
* 这次写个5-test.lua服务，并从中启动2个1-test.lua服务
```lua
local skynet = require "skynet"

skynet.start(function()
    skynet.error("My new  service")
    skynet.newservice("1-test")
    skynet.error("new test service 0")
    skynet.newservice("1-test")
    skynet.error("new test servece 1")
end)
```
*运行结果如下*
```bash
[:01000002] LAUNCH snlua bootstrap
[:01000003] LAUNCH snlua launcher
[:01000004] LAUNCH snlua cmaster
[:01000004] master listen socket 0.0.0.0:2013
[:01000005] LAUNCH snlua cslave
[:01000005] slave connect to master 127.0.0.1:2013
[:01000004] connect from 127.0.0.1:37982 4
[:01000006] LAUNCH harbor 1 16777221
[:01000004] Harbor 1 (fd=4) report 127.0.0.1:2526
[:01000005] Waiting for 0 harbors
[:01000005] Shakehand ready
[:01000007] LAUNCH snlua datacenterd
[:01000008] LAUNCH snlua service_mgr
[:01000009] LAUNCH snlua main
[:01000009] Server start
[:0100000a] LAUNCH snlua protoloader
[:0100000b] LAUNCH snlua console
[:0100000c] LAUNCH snlua debug_console 8000
[:0100000c] Start debug console at 127.0.0.1:8000
[:0100000d] LAUNCH snlua simpledb
[:0100000e] LAUNCH snlua watchdog
[:0100000f] LAUNCH snlua gate
[:0100000f] Listen on 0.0.0.0:8888
[:01000009] Watchdog listen on 8888
[:01000009] KILL self
[:01000002] KILL self
5-test
[:01000010] LAUNCH snlua 5-test
[:01000010] My new  service
[:01000012] LAUNCH snlua 1-test
[:01000012] 第一个程序-为熟悉skynet
[:01000010] new test service 0
[:01000019] LAUNCH snlua 1-test
[:01000019] 第一个程序-为熟悉skynet
[:01000010] new test servece 1
```
#### 4.2 全局唯一服务
* 全局唯一服务等同于单例，即不管调用多少次创建接口，最后都只会创建一个类似的服务实例，且全局唯一。使用的创建接口是:
```lua
skynet.uniqueservice(servicename, ...)
skynet.uniqueservice(true,servicename, ...)
```
*当带参数`true`时,则表示此服务在所有节点之间是全局唯一的,否则表示此服务只在当前skynet节点全局唯一。第一次创建唯一服务，返回服务地址，之后再创建的时候不会正常创建服务，只是返回第一次创建的服务地址。*
* 查询接口: 假如不清楚当前是否创建了某个全局服务，可以通过以下接口来查询:
```lua
skynet.queryservice(servicename, ...)
skynet.queryservice(true, servicename, ...)
```
*如果还没有创建过目标服务则一直等下去，直到目标服务被（其他服务触发而）创建。*

*当参数带`true`时,则表示查询在所有节点中唯一的服务是否存在。*
* ***接下来我们操作一下***
* 首先创建出我们的第六个测试程序6-test,键入以下代码:
```lua
local skynet = require "skynet"

--这里创建两个只是为了方便观看，其实一个就够
local args = { ... }

table.insert(args,1,"1-test")
table.insert(args,1,"1-test")


skynet.start(function()
    skynet.error(args[1],args[2],#args)
    local us1 = 0
    local us2 = 0
    skynet.error("test unique service")

    skynet.error("1,所有")
    us1 = skynet.uniqueservice(true,args[1])

    skynet.error("2,当前")
    us2 = skynet.uniqueservice(args[2])   --这里args[1]和args[2]都一样

    skynet.error("1-test handler:", skynet.address(us1)) 
    skynet.error("1-test handler:", skynet.address(us2)) 
end)
```
*运行结果如下*
```bash
[:01000002] LAUNCH snlua bootstrap
[:01000003] LAUNCH snlua launcher
[:01000004] LAUNCH snlua cmaster
[:01000004] master listen socket 0.0.0.0:2013
[:01000005] LAUNCH snlua cslave
[:01000005] slave connect to master 127.0.0.1:2013
[:01000004] connect from 127.0.0.1:39346 4
[:01000006] LAUNCH harbor 1 16777221
[:01000004] Harbor 1 (fd=4) report 127.0.0.1:2526
[:01000005] Waiting for 0 harbors
[:01000005] Shakehand ready
[:01000007] LAUNCH snlua datacenterd
[:01000008] LAUNCH snlua service_mgr
[:01000009] LAUNCH snlua main
[:01000009] Server start
[:0100000a] LAUNCH snlua protoloader
[:0100000b] LAUNCH snlua console
[:0100000c] LAUNCH snlua debug_console 8000
[:0100000c] Start debug console at 127.0.0.1:8000
[:0100000d] LAUNCH snlua simpledb
[:0100000e] LAUNCH snlua watchdog
[:0100000f] LAUNCH snlua gate
[:0100000f] Listen on 0.0.0.0:8888
[:01000009] Watchdog listen on 8888
[:01000009] KILL self
[:01000002] KILL self
6-test
[:01000010] LAUNCH snlua 6-test
[:01000010] 1-test 1-test 2
[:01000010] test unique service
[:01000010] 1,所有
[:01000012] LAUNCH snlua 1-test
[:01000012] 第一个程序-为了熟悉skynet
[:01000010] 2,当前
[:01000019] LAUNCH snlua 1-test
[:01000019] 第一个程序-为了熟悉skynet
[:01000010] 1-test handler: :01000012
[:01000010] 1-test handler: :01000019
^C
lsh@lsh-virtual-machine:~/fuxi/skynet$ ./skynet   examples/config
[:01000002] LAUNCH snlua bootstrap
[:01000003] LAUNCH snlua launcher
[:01000004] LAUNCH snlua cmaster
[:01000004] master listen socket 0.0.0.0:2013
[:01000005] LAUNCH snlua cslave
[:01000005] slave connect to master 127.0.0.1:2013
[:01000004] connect from 127.0.0.1:39446 4
[:01000006] LAUNCH harbor 1 16777221
[:01000004] Harbor 1 (fd=4) report 127.0.0.1:2526
[:01000005] Waiting for 0 harbors
[:01000005] Shakehand ready
[:01000007] LAUNCH snlua datacenterd
[:01000008] LAUNCH snlua service_mgr
[:01000009] LAUNCH snlua main
[:01000009] Server start
[:0100000a] LAUNCH snlua protoloader
[:0100000b] LAUNCH snlua console
[:0100000c] LAUNCH snlua debug_console 8000
[:0100000c] Start debug console at 127.0.0.1:8000
[:0100000d] LAUNCH snlua simpledb
[:0100000e] LAUNCH snlua watchdog
[:0100000f] LAUNCH snlua gate
[:0100000f] Listen on 0.0.0.0:8888
[:01000009] Watchdog listen on 8888
[:01000009] KILL self
[:01000002] KILL self
6-test
[:01000010] LAUNCH snlua 6-test
[:01000010] 1-test 1-test 2
[:01000010] test unique service
[:01000010] 1,所有
[:01000012] LAUNCH snlua 1-test
[:01000012] 第一个程序-为了熟悉skynet
[:01000010] 2,当前
[:01000019] LAUNCH snlua 1-test
[:01000019] 第一个程序-为了熟悉skynet
[:01000010] 1-test handler: :01000012
[:01000010] 1-test handler: :01000019
6-test
[:0100001a] LAUNCH snlua 6-test
[:0100001a] 1-test 1-test 2
[:0100001a] test unique service
[:0100001a] 1,所有
[:0100001a] 2,当前
[:0100001a] 1-test handler: :01000012
[:0100001a] 1-test handler: :01000019
```
***从运行结果可知：第一次执行6-test时，可得到当前节点的全局唯一与所有节点的全局唯一是可以共同存在这一结论。但当我们第二次执行6-test时，并没有产生新的服务，只是把已经创建好的全局唯一服务的句柄给返回了，可得到此服务全局唯一的结论***
* 然后我们创建我们的第七份测试代码7-test.lua,键入以下代码
```lua
local skynet = require "skynet"

--这里创建两个只是为了方便观看，其实一个就够
local args = { ... }

table.insert(args,1,"1-test")
table.insert(args,1,"1-test")


skynet.start(function()
    skynet.error(args[1],args[2],#args)
    local us1 = 0
    local us2 = 0
    skynet.error("test unique service")

    skynet.error("1,所有")
    us1 = skynet.queryservice(true,args[1])

    skynet.error("2,当前")
    us2 = skynet.queryservice(args[2])  

    skynet.error("1-test handler:", skynet.address(us1)) 
    skynet.error("1-test handler:", skynet.address(us2)) 
end)
```
*运行结果如下*
```bash
[:01000009] Watchdog listen on 8888
[:01000009] KILL self
[:01000002] KILL self
7-test
[:01000010] LAUNCH snlua 7-test
[:01000010] 1-test 1-test 2
[:01000010] test unique service
[:01000010] 1,所有
```
`本结果只截取关键部分`

***直接运行后，可见代码阻塞至us1 = sk..... 处。注释调它之后，在us2 = sk......处也会阻塞（可以自行验证）***

***下面我们先创建出全局唯一服务——即先执行6-test，再执行7-test看下能否能通过服务名查询到其对应的全局唯一服务句柄***

*运行结果如下*
```bash
[:01000002] KILL self
6-test
[:01000010] LAUNCH snlua 6-test
[:01000010] 1-test 1-test 2
[:01000010] test unique service
[:01000010] 1,所有
[:01000012] LAUNCH snlua 1-test
[:01000012] 第一个程序-为熟悉skynet
[:01000010] 2,当前
[:01000019] LAUNCH snlua 1-test
[:01000019] 第一个程序-为熟悉skynet
[:01000010] 1-test handler: :01000012
[:01000010] 1-test handler: :01000019
7-test
[:0100001a] LAUNCH snlua 7-test
[:0100001a] 1-test 1-test 2
[:0100001a] test unique service
[:0100001a] 1,所有
[:0100001a] 2,当前
[:0100001a] 1-test handler: :01000012
[:0100001a] 1-test handler: :01000019
```
`本结果只截取关键部分`

***所以我们查询时要注意所需要查询的全局唯一服务句柄是所有节点的还是当前节点的（也就是加不加true）***
#### 4.3-多节点中的全局服务

#### 4.3.1 启动两个skynet节点
* 首先，我们先启动两个节点出来。copy两份examp/config为2-test与3-test，2-test中修改如下:
```shell
include "config.path"

-- preload = "./examples/preload.lua"	-- run preload.lua before every lua service run
thread = 8
logger = nil
logpath = "."
harbor = 1        --表示每个节点的编号
address = "127.0.0.1:2526"
master = "127.0.0.1:2013"
start = "console"	-- main script  启动一个console.lua服务
bootstrap = "snlua bootstrap"	-- The service for bootstrap
standalone = "0.0.0.0:2013"     --主节点才会用到这个，绑定地址
-- snax_interface_g = "snax_g"
cpath = root.."cservice/?.so"
-- daemon = "./skynet.pid"
```
* 3-test中修改如下
```shell
include "config.path"

-- preload = "./examples/preload.lua"	-- run preload.lua before every lua service run
thread = 8
logger = nil
logpath = "."
harbor = 2           --编号需要改
address = "127.0.0.1:2527"       --改一个跟2-test不同的端口
master = "127.0.0.1:2013"        --主节点地址不变
start = "console"	-- main script
bootstrap = "snlua bootstrap"	-- The service for bootstrap
--standalone = "0.0.0.0:2013"   -- 从节点不需要这个，注释掉
-- snax_interface_g = "snax_g"
cpath = root.."cservice/?.so"
-- daemon = "./skynet.pid"
```
* 启动第一个节点 
```shell
$ ./skynet examples/2-test 
```
```bash
[:01000002] LAUNCH snlua bootstrap
[:01000003] LAUNCH snlua launcher
[:01000004] LAUNCH snlua cmaster    #启动主节点cmaster(控制)服务
[:01000004] master listen socket 0.0.0.0:2013     #监听端口2013
[:01000005] LAUNCH snlua cslave   #主节点也要启动一个cslave(会话),去连接cmaster节点
[:01000005] slave connect to master 127.0.0.1:2013 #cslave中一旦连接完cmaster就会启动一个harbor服务
[:01000004] connect from 127.0.0.1:41840 4
[:01000006] LAUNCH harbor 1 16777221 #cslave启动一个Harbor（入港停泊）服务，用于节点间通信
[:01000004] Harbor 1 (fd=4) report 127.0.0.1:2526 #报告cmaster  cslave服务的地址
[:01000005] Waiting for 0 harbors #cmaster告诉cslave还有多少个其他cslave需要连接
[:01000005] Shakehand ready    #cslave与cmaster握手成功
[:01000007] LAUNCH snlua datacenterd
[:01000008] LAUNCH snlua service_mgr
[:01000009] LAUNCH snlua console
[:01000002] KILL self
[:01000004] connect from 127.0.0.1:41950 6  #cmaster收到其他cslave连接请求
[:01000004] Harbor 2 (fd=6) report 127.0.0.1:2527 #其他cslave报告地址
[:01000005] Connect to harbor 2 (fd=7), 127.0.0.1:2527  #让当前cslave去连接其他cslave
```
* 启动第二个节点
```shell
$ ./skynet examples/3-test 
```
```bash
[:02000002] LAUNCH snlua bootstrap
[:02000003] LAUNCH snlua launcher
[:02000004] LAUNCH snlua cslave
[:02000004] slave connect to master 127.0.0.1:2013   #cslave去连接主节点的cmaster服务
[:02000005] LAUNCH harbor 2 33554436     #cslave也启动一个harbor服务
[:02000004] Waiting for 1 harbors       #等待主节点的cslave来连接
[:02000004] New connection (fd = 3, 127.0.0.1:35730)   #cslave与主节点cslave连接成功
[:02000004] Harbor 1 connected (fd = 3)
[:02000004] Shakehand ready       #cslave与cmaster握手成功
[:02000006] LAUNCH snlua service_mgr
[:02000007] LAUNCH snlua console
[:02000002] KILL self
```

#### 4.3.2 测试多节点全局唯一服务
**我们在节点2中，启动查询全局节点服务，查看现象1；之后在节点1中分别创建所有节点的全局唯一服务，和节点1的全局唯一服务，查看现象2；最后在节点2中分别创建所有节点的全局唯一服务，和节点2的全局唯一服务，查看现象3**
* 新建第八个测试文件作为创建节点文件(8-test.lua)，键入以下代码:
```lua
local skynet = require "skynet"

local args = { ... }

skynet.start(function()
    skynet.error(args[1],args[2],#args)
    local us1 = 0
    local us2 = 0
    skynet.error("test unique service")

    skynet.error("1,所有")
    us1 = skynet.uniqueservice(true,args[1])

    skynet.error("2,当前")
    us2 = skynet.uniqueservice(args[2])   --这里args[1]和args[2]都一样

    skynet.error("1-test handler:", skynet.address(us1)) 
    skynet.error("1-test handler:", skynet.address(us2)) 
end)
```
* 新建第九个测试文件作为查询节点文件(9-test.lua),键入以下代码:
```lua
local skynet = require "skynet"

local args = { ... }

skynet.start(function()
    skynet.error(args[1],args[2],#args)
    local us = 0
    skynet.error("test unique service")

    skynet.error("1,所有")
    us = skynet.queryservice(true,args[1])

    skynet.error("1-test handler:", skynet.address(us)) 
end)
```
*现象一，运行结果如下*
```bash
9-test 1-test
[:0200000f] LAUNCH snlua 9-test 1-test
[:0200000f] 1-test nil 1
[:0200000f] test unique service
[:0200000f] 1,所有
```
***现象一：由于在节点2中检测不到名为1-test的所有节点的全局唯一服务，故阻塞等待，一旦这个服务开启，我们会立马获得其地址***

*现象二，运行结果如下*

`首先是节点2中的现象`
```bash
9-test 1-test
[:0200000f] LAUNCH snlua 9-test 1-test
[:0200000f] 1-test nil 1
[:0200000f] test unique service
[:0200000f] 1,所有
[:0200000f] 1-test handler: :0100000b
```
`其次是节点1中的现象`
```bash
8-test 1-test 1-test
[:0100000a] LAUNCH snlua 8-test 1-test 1-test
[:0100000a] 1-test 1-test 2
[:0100000a] test unique service
[:0100000a] 1,所有
[:0100000b] LAUNCH snlua 1-test
[:0100000b] 第一个程序-为熟悉skynet
[:0100000a] 2,当前
[:0100000c] LAUNCH snlua 1-test
[:0100000c] 第一个程序-为熟悉skynet
[:0100000a] 1-test handler: :0100000b
[:0100000a] 1-test handler: :0100000c
```
***现象二:跟我们猜想的一样，获得了两个全局唯一服务***

*现象三，运行结果如下:*
```bash
8-test 1-test 1-test
[:02000010] LAUNCH snlua 8-test 1-test 1-test
[:02000010] 1-test 1-test 2
[:02000010] test unique service
[:02000010] 1,所有
[:02000010] 2,当前
[:02000012] LAUNCH snlua 1-test
[:02000012] 第一个程序-为熟悉skynet
[:02000010] 1-test handler: :0100000b
[:02000010] 1-test handler: :02000012
```
***现象三：我们可以看到，我们的所有节点全局唯一服务并没有创建出来，只是返回了已有所有节点全局唯一服务的地址。而我们成功创建了节点1的全局唯一服务。所以我们最终得到了3个名字相同的全局唯一服务***
******
###### 从这个分割点开始，笔记只写接口，复习看视频，想要深入看云风的教程和博客。这次学习，本意就是快速入门，理解思想，不然总是在视频上浪费功夫。而且经过前几个视频的详细罗嗦，就算这个视频真有人看着学的话后面快一点也没关系了，毕竟只是通过对作者封装的API的学习使用，来快速了解以下这个项目，而且我这边学编录的也快不到哪里去。
******
## 5-服务别名
```bash
* 在skynet中，服务别名可以分为两种：
    --本地别名:本地别名只能在当前skynet节点使用，本地别名必须使用. 开头，例如：.testalias
    --全局别名:全局别名可以在所有skynet中使用，全局别名不能以. 开头， 例如：testalias
   注意:本地别名和全局别名可以同时存在。
* 在skynet中，服务别名既可以给普通服务起别名，也可以给全局唯一服务其别名
   注意: 不要把查询服务别名获得地址（句柄）的接口 harbor.queryname(aliasname) ,和查询全局唯一服务获得地址（句柄）的接口 skynet.(queryservice) 弄混了。
```
* 别名注册与查询接口
```lua
--[[取别名]]
local skynet = require "skynet"
require "skynet.manager"
​
--给当前服务定一个别名，可以是全局别名，也可以是本地别名
skynet.register(aliasname)
​
--给指定sericehandler地址（句柄）的服务定一个别名，可以是全局别名，也可以是本地别名
--我们配合skynet.self()，的话也可以给当前服务起别名了
skynet.name(aliasname, servicehandler)

----------------------------------------------------------------------------------------
-[查询别名]
--查询本地别名为.aliasname的服务，返回其地址（句柄)，不存在就返回nil
skynet.localname(.aliasname)   --只能查本地
​
--[[
查询别名为aliasname的服务,可以是全局别名也可以是本地别名,返回其地址(句柄)
1、当查询本地别名时，返回servicehandler，不存在就返回nil
2、当查询全局别名时，返回servicehandler，不存在就阻塞等待到该服务初始化完成
]]--
local harbor = require "skynet.harbor"
harbor.queryname(aliasname)  --用之前记得加载模块，记得给模块取个别名
```
* 如果我们杀死带别名的服务，本地别名将会注销掉，但是全局别名依然存在，通过全局别名查询到的handle已经没有意义。如果通过handle进行一些操作将得到不可预知的问题。

`全局别名一般用来给一个永远不会退出的服务来启用。`

​`skynet的全局别名服务是在cslave里面实现的，实现里不允许二次修改全局别名绑定关系。`

​`但是有些情况下，我们确实需要二次修改全局别名绑定关系，那么这个时候，我们可以尝试去修改一下cslave.lua文件，修改内容如下:`
```lua
function harbor.REGISTER(fd, name, handle)
    --assert(globalname[name] == nil)  --将这一行注释掉
    globalname[name] = handle
    response_name(name)
    socket.write(fd, pack_package("R", name, handle))
    skynet.redirect(harbor_service, handle, "harbor", 0, "N " .. name)
end
```
## 6-服务调度
`接口`
```lua
local skynet = require "skynet"    //模块

--延时函数   time * 0.01s
skynet.sleep(time)

--创建协程，返回句柄，参数为回调函数和其参数。
--创建的携程，在主协程运行完后，才会唤醒执行。
--虽然可以用原生的coroutine.create来创建携程，但是会打乱skynet的工作流程，不推荐。
skynet.fork(func,...)

--将携程挂起,随后继续运行
skynet.yield()

--将携程挂起，直到用 wakeup 唤醒它
skynet.wait()

--唤醒用 wait 或 sleep 处于等待状态的任务
skynet.wakeup(co)

--设定一个定时触发函数 func ，在 time * 0.01s 后触发
skynet.timeout(time,func)

--返回当前进程的启动 UTC 时间(秒)。
skynet.starttime()

--返回当前进程启动后经过的时间（0.01秒）。
skynet.now()

--通过 starttime 和 now 计算出当前 UTC 时间（秒）。
skynet.time()

```
`总结：`
```bash
  1-在当前协程中使用skynet.sleep()睡眠后，因为阻塞了窗口无法启动其他服务。
  2-在当前协程执行完毕后(或阻塞后)，启动其他协程，其他携程中执行skynet.sleep()睡眠阻塞时,由于当前窗口没有阻塞我们启动了其他服务。
  3-由于阻塞期间正常执行了其他协程，说明阻塞时不影响其余协程的执行。
  4-在当前携程执行完毕后，执行其他携程，协程运行时会长时间占用执行权限，结束后才能执行另一个协程。但我们可以通过挂起接口skynet.yield(),来让处执行权限，让其他协程先运行。
```
#### skynet中的异常处理
* lua中的异常处理 :  assert , error , pcall , xpcall   
* skynet的异常处理直接使用的lua的API，并没有再次封装。
## 7-服务间消息通信
`介绍`
```markdown
* 介绍
​ skynet中的每一个服务都有一个独立的lua虚拟机，逻辑上服务之间是相互隔离的，那么你就不能使用传统意义上的LUA全局变量来进行服务间通信了。

​ 在skynet中服务之间可以通过skynet消息调度机制来完成通信。skynet中的服务是基于actor模型设计出来的，每个服务都可以接收消息，处理消息，发送应答消息。

​ 每条 skynet 消息由 6 部分构成：消息类型、session 、发起服务地址 、接收服务地址 、消息 C 指针、消息长度。

* 消息类型
结构体中的type
在 skynet 中消息分为多种类别，对应的也有不同的编码方式（即协议），数据结构中用type表示，消息类型的宏定义可以查看 skynet.h 中：
***
#define PTYPE_TEXT 0   
#define PTYPE_RESPONSE 1    //表示一个回应包
#define PTYPE_MULTICAST 2   //广播消息
#define PTYPE_CLIENT 3      //用来处理网络客户端的请求消息
#define PTYPE_SYSTEM 4      //系统消息
#define PTYPE_HARBOR 5      //跨节点消息
#define PTYPE_SOCKET 6    //套接字消息
#define PTYPE_ERROR 7     //错误消息，一般服务退出的时候会发送error消息给关联的服务
#define PTYPE_QUEUE 8
#define PTYPE_DEBUG 9
#define PTYPE_LUA 10   //lua类型的消息，最常用
#define PTYPE_SNAX 11  //snax服务消息
​
#define PTYPE_TAG_DONTCOPY 0x10000
#define PTYPE_TAG_ALLOCSESSION 0x20000
***
上面的消息类型有多种，但是最常用的是PTYPE_LUA，对应到lua层，叫做lua消息 ，大部分服务一般使用这种消息，默认情况下，PTYPE_REPSONSE、PTYPE_ERROR、PTYPE_LUA三种消息类型已经注册（查看源码了解情况），如果想使用其他的消息类型，需要自己显示注册消息 类型。
```
`接口`
```lua
--注册"lua"类型消息的回调函数,注意使用到别名需加载模块 require "skynet.manager"
skynet.dispatch("lua", function(session, address, ...)
    dosomething(...)
end)

《打包与解包》
--打包后，会返回两个参数，一个是C指针msg指向数据包的起始地址，sz一个是数据包的长度。msg指针的内存区域是动态申请的。
skynet.pack(...)     --打包函数

--解包后，会返回一个参数列表。需要注意这个时候C指针msg指向的内存不会释放掉。如果msg有实际的用途，skynet框架会帮你在合适的地方释放掉，如果没有实际的用途，自己想释放掉可以使用 skynet.trash(msg, sz)释放掉。
skynet.unpack(msg, sz)    --解包函数

skynet.trash(msg, sz)     --free调msg所指向的堆区空间，用到skynet框架中的话会自动释放

《发送消息的方法》
1.发送无须响应的消息
--用 type 类型向 addr 发送未打包的消息。该函数会自动把...参数列表进行打包，默认情况下lua消息使用skynet.pack打包。addr可以是服务句柄也可以是别名。
skynet.send(addr, type, ...)
--用 type 类型向 addr 发送一个打包好的消息。addr可以是服务句柄也可以是别名。
skynet.rawsend(addr, type, msg, sz) 

2.发送必须响应的消息
--用默认函数打包消息，向addr发送type类型的消息并等待返回响应，并对回应信息进行解包。（自动打包与解包。）
skynet.call(addr, type, ...) 
--直接向addr发送type类型的msg,sz并等待返回响应，不对回应信息解包。（需要自己打包与解包）
skynet.rawcall(addr, type, msg, sz) 

《响应消息》
消息到达时，我们的协程句柄会与对方的服务地址对应到table中。
是根据自己所在协程的句柄对应table中的对方的服务地址,如果是新开辟了一个协程，那么我们的table中是找不到对应的地址的
1.无法在其他协程中响应
--回复自己打包的消息
skynet.ret(msg,sz)     
--回复消息（自动打包）
skynet.retpack(...)

2.在其他协程中响应的方法
local response = skynet.response(pack)
--pack：响应消息打包函数，默认为 skynet.pack；
--返回值：一个闭包函数。
 response(ok, …)
--参数 ok 的值可以是：
    “test”：检查接收响应的服务是否存在；
    true：发送应答 PTYPE_RESPONSE；
    false：发送 PTYPE_ERROR 错误消息。

《服务间通信容易遇到的问题》
1.skynet.call失败的情况：也就是在等待服务响应时服务却意外退出了
现象：响应服务退出后，会给到skynet.call一个error的错误消息,所以请求服务接收后会直接报错。

2.服务重入的情况 :  我服务接收消息是当下的，如果同一时刻有多条消息到达，只会处理最后到达的那一条消息。由于我们的服务在阻塞期间依旧可以接收消息，因此我们可以通过阻塞API来模拟这个现象，从而验证。(只要请求发送足够频繁，就会存在重入的问题)

3.服务临界区  :  skynet.queue 模块可以帮助你回避这些服务重入或者伪并发引起的复杂性,下面是使用方法：
local queue = require "skynet.queue"
local cs = queue()  --获取一个执行队列
cs(fun, ...) --将f丢到队列中执行
缺点：执行队列虽然解决了重入的问题，但是明显降低了服务的并发处理能力，所以使用执行队列的时候尽量缩小临界区的颗粒度大小。

《注册其他type的消息》
--举个例子：
skynet.register_protocol {         --注册system消息
    name = "system",
    id = skynet.PTYPE_SYSTEM,
    --pack = skynet.pack,
    unpack = skynet.unpack, --unpack必须指定一下，接收到消息后会自动使用unpack解析
}


《代理服务》
顾名思义，就是两人之间打电话，电话就是代理。代理服务就是这样一个角色，请求者和响应者都只能与代理服务交互，由代理服务转达双方消息。

由于服务默认接收到lua消息后，会解包消息，影响代理转发效率。而且lua消息已经注册了无法更改，所以使用skynet.forward_type进行协议转换。

--使用skynet.forward_type也是启动服务的一种方法，跟skynet.start类似，只不过skynet.forward_type还需要提供一张消息转换映射表forward_map, 其他的方法与skynet.start一样。
skynet.forward_type( forward_map ,function() end )

local forward_map = {
    --发送到代理服务的lua消息全部转成system消息,不改变原先LUA的消息协议处理方式
    [skynet.PTYPE_LUA] = skynet.PTYPE_SYSTEM,
    --如果接收到应答消息，默认情况下会释放掉消息msg,sz，forward的方式处理消息不会释放掉消息msg,sz
    [skynet.PTYPE_RESPONSE] = skynet.PTYPE_RESPONSE,    
}
表的定义方法：
    Lua 5.4.3  Copyright (C) 1994-2021 Lua.org, PUC-Rio
    > a = {[5]=6}  print(a[5])
    6
    > a = {[s]=6}  print(a[s])
    stdin:1: table index is nil
    stack traceback:
    stdin:1: in main chunk
    [C]: in ?
    > b = {["s"]=2}   a = {[b.s] = 6}   print(a[b.s])    print("----")   print(a[2])
    6
    ----
    6


《伪造消息》
local skynet = require "skynet" 
--使用source服务地址，发送typename类型的消息给dest服务，不需要接收响应，（source，dest只能是服务ID）
--msg sz一般使用skynet.pack打包生成
skynet.redirect(dest,source,typename, session, msg, sz)

《节点间消息通信》
使用全局别名就OK

```
## 8-组播
`接口`
```lua
--引入组播模块
local mc = require "skynet.multicast"

​--你可以通过 new 函数来创建一个频道对象。你可以创建一个新频道，也可以利用已知的频道 id 绑定一个已有频道。
local channel = mc.new()  -- 创建一个频道，成功创建后，channel.channel 是这个频道的 id 。

--定义一个频道，加入上句代码刚创建的频道。如果表内channel没有赋值一个频道id，则创建一个新的频道出来（又成�默认用法了）
local channel2 = mc.new {
  channel = channel.channel,  -- 加入多播频道
  dispatch = function (channel, source, ...) end,  -- 设置这个频道的消息处理函数
}
​* 通常，由一个服务创建出频道，再将 .channel 这个 id 通知别的地方。获得这个 id 的位置，都可以绑定这个频道。

--向一个频道发布消息。消息可以是任意数量合法的 lua 值。
channel:publish(...) 

--绑定到一个频道后，默认并不接收这个频道上的消息（也许你只想向这个频道发布消息）。这个接口用来订阅它，定月后接收
channel:subscribe()

--取消订阅
channel:unsubscribe

--回收频道，频道不用的时候记得回收
channel:delete()
--注：多次调用 channel:delete 是无害的，因为 channel id 不会重复使用。在频道被销毁后再调用 subscribe 或 publish 等也不会引起异常，但订阅是不起作用的，消息也不再广播。
```
## 9-socket网络服务
`接口`
```lua
--socket模块 。
local socket = require "skynet.socket"
​
--建立一个 TCP 连接。返回一个数字 id 。
socket.open(address, port)      
​
--关闭一个连接，这个 API 有可能阻塞住执行流。
socket.close(id)
​
--在极其罕见的情况下，需要粗暴的直接关闭某个连接，而避免 socket.close 的阻塞等待流程，可以使用它。
socket.close_fd(id)
​
--强行关闭一个连接。和 close 不同的是，它不会阻塞执行流
socket.shutdown(id)
​
--[[
    从一个 socket 上读 sz 指定的字节数。
    如果读到了指定长度的字符串，它把这个字符串返回。
    如果连接断开导致字节数不够，将返回一个 false 加上读到的字符串。
    如果 sz 为 nil ，则返回尽可能多的字节数，但至少读一个字节（若无新数据，会阻塞）。
--]]
socket.read(id, sz)
​
--从一个 socket 上读所有的数据，只要连接还在就会一直阻塞。
--直到 socket 主动断开，或在其它 coroutine 用 socket.close 关闭它,才会解除阻塞并将所有数据返回。
--使用socket.abandon(id) 也可以解除阻塞返回数据
socket.readall(id)
​
--从一个 socket 上读一行数据。sep 指行分割符。默认的 sep 为 "\n"。读到的字符串是不包含这个分割符的。
--如果另外一端就关闭了，那么这个时候会返回一个nil，如果buffer中有未读数据则作为第二个返回值返回。
socket.readline(id, sep) 
​
--等待一个 socket 可读。
socket.block(id) 
​
 
--把一个字符串置入正常的写队列，skynet 框架会在 socket 可写时发送它。
socket.write(id,str) 
​
--把字符串写入低优先级队列。如果正常的写队列还有写操作未完成时，低优先级队列上的数据永远不会被发出。
--只有在正常写队列为空时，才会处理低优先级队列。但是，每次写的字符串都可以看成原子操作。
--不会只发送一半，然后转去发送正常写队列的数据。
socket.lwrite(id,str) 
​
--监听一个端口，返回一个 id ，供 start 使用。
socket.listen(address, port) 
​
--[[
    accept 是一个函数。每当一个监听的 id 对应的 socket 上有连接接入的时候，都会调用 accept 函数。
这个函数会得到接入连接的 id 以及 ip 地址。你可以做后续操作。
    每当 accept 函数获得一个新的 socket id 后，并不会立即收到这个 socket 上的数据。
这是因为，我们有时会希望把这个 socket 的操作权转让给别的服务去处理。accept(id, addr)
]]--
socket.start(id , accept) 
​
--[[
    任何一个服务只有在调用 socket.start(id) 之后，才可以读到这个 socket 上的数据。
向一个 socket id 写数据也需要先调用 start 。
    socket 的 id 对于整个 skynet 节点都是公开的。也就是说，你可以把 id 这个数字
通过消息发送给其它服务，其他服务也可以去操作它。skynet 框架是根据调用 start 这个 
api 的位置来决定把对应 socket 上的数据转发到哪里去的。
--]]
socket.start(id)
​
--清除 socket id 在本服务内的数据结构，但并不关闭这个 socket 。
--这可以用于你把 id 发送给其它服务，以转交 socket 的控制权。
socket.abandon(id) 
​
--[[
    当 id 对应的 socket 上待发的数据超过 1M 字节后，系统将回调 callback 以示警告。
function callback(id, size) 回调函数接收两个参数 id 和 size ，size 的单位是 K 。
    如果你不设回调，那么将每增加 一倍 利用 skynet.error 写一行错误信息。
--]]
socket.warning(id, callback) 

```