# hunt-imf
## Introduction
hunt-imf is a tcp-based instant messaging framework and can be used for Push service, Chat service, Game service, etc.
* serializes messages using [protobuf](https://github.com/protobuf)
* uses binary protocol (type & length)
* implements message distribution, message routing, and network IO
* ensure that all messages in the same context are serialized

## Depends
* [protobuf](https://github.com/dcarp/protobuf-d)
* [hunt-net](https://github.com/huntlabs/hunt-net)

## Tools
* `protoc`  *apt-get install protoc-compile*
* [protoc-gen-d](https://github.com/dcarp/protobuf-d/tree/master/protoc_gen_d)

## examples
* `helloworld` *An executable program containing the server and the client*
* `chatroom` *two executable programs include chatclient and chatserver*

## build
* `hunt-imf` *dub build *
* `helloworld` *dub build -c=helloworld*
* `chatclient` *dub build -c=chatclient*
* `chatserver` *dub build -c=chatserver*

## Quick start
### Proto
* define a `.proto` file named `helloworld.proto`:
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
* using `protoc` and `protoc-gen-d` compiles `helloworld.proto` to `hellowrold.d` , command below:
```shell
./protoc --plugin="protoc-gen-d" --d_out=~/example/  -I~/example/hellowrold ~/hellworld.proto
```

### COMMAND
define a `dlang` source file named command.d:
 ```D
 enum COMMAND
 {
    HELO_REQ = 1001,
    HELO_RES = 1002,
 }
 ```


### Controller
* define a server side control class:
```D
class ServerController
{
    mixin MakeRouter;

    @route(COMMAND.HELO_REQ)
    void hello(HelloRequest request)
    {
        auto reply = new HelloReply();
        reply.message = "hello " ~ request.name;
        sendMessage(context , Command.R_HELO , reply);

    }
}
```
* define a client size control class:
```D
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


### Bootstrap
```D
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
