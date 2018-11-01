# hunt-imf
## 说明  
 hunt-imf是基于tcp的即时消息框架，可用于推送，聊天，游戏等服务。  
 1 使用protobuf对消息进行序列化  
 2 使用二进制协议TL(type & length)风格  
 3 封装了消息分发，消息路由以及网络IO  
 4 保证同一个会话的所有消息串行化  
 使用hunt-imf可以高效关注业务消息流程开发。

## 编译
编译库： 
```d
dub build
```
编译helloworld样例:
```d
dub build -c=helloworld
```
编译chatclient样例:
```d
dub build -c=chatclient
```
编译chatserver样例:
```d
dub build -c=chatroom
```  

## 样例
helloworld为一个基本的样例，服务端及客户端在同一个执行文件中。   
chatroom为一个聊天室样例，chatserver为服务端，chatclient为客户端。



## 快速开始
### 定义helloworld.proto:
 ```proto
syntax = "proto3";
package helloworld;

// The request message containing the user's name.
message HelloRequest {
  string name = 1;
}

// The response message containing the greetings
message HelloReply {
  string message = 1;
}
 ```
 使用 protoc及protoc-gen-d 将helloworld.proto编译成d语言代码。
     
 protoc:
 ```
 apt-get install protoc-compile
 ```
 protoc-gen-d:
 ```
 git clone https://github.com/dcarp/protobuf-d 
 ```
 
### 定义一个command.d:
 ```
 enum COMMAND
 {
    HELO_REQ = 1001,
    HELO_RES = 1002,
 }
 ```
### 定义处理的HELO_REQ的Controller
```
class ServerController
{
    mixin MakeRouter;

    @route(COMMAND.HELO_REQ)
    void hello(HelloRequest request)
    {
        writeln("server hello " , getTid());
        auto reply = new HelloReply();
        reply.message = "hello " ~ request.name;
        sendMessage(context , Command.R_HELO , reply);

    }
}
```
```
mixin MakeRouter 这个类会被当作路由处理。  
```

```
@route(COMMAND.HELO_REQ)  
void hello(HelloRequest request)  
框架收到1001(COMMAND.HELO_REQ),消息格式为HelloRequest，则会调用hello方法。
```
### 定义处理HELO_REQ的Controller
```
class ClientController
{
    mixin MakeRouter;

    @route(Command.R_HELO)
    void hello(HelloReply reply)
    {
        writeln(reply.message);
    }

}
```
### 启动代码
```
   auto app = new Application();
   
   auto server = app.createServer("127.0.0.1" , 3003);
   auto client = app.createClient("127.0.0.1" , 3003);
   client.setOpenHandler((Context context){
       auto hello = new HelloRequest();
       hello.name = "world";
       context.sendMessage(Command.Q_HELO , hello);
   });
   app.run();  
```
