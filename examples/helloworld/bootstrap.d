
import hunt.imf;

import helloworld.command;
import helloworld.helloworld;

import std.stdio;

import hunt.concurrent.thread;
        
class ServerService
{
    mixin MakeRouter;

    @route(Command.Q_HELO)
    void hello(HelloRequest request)
    {
        writeln("server hello " , getTid());
        auto reply = new HelloReply();
        reply.message = "hello " ~ request.name;
        sendMessage(context , Command.R_HELO , reply);

    }

    
    @route(Command.Q_HEART)
    void heart()
    {
        writeln("server heart" , getTid());
        sendMessage(context , Command.Q_HEART);
    }
}

@namespace("client")
class ClientService
{
    mixin MakeRouter;

    @route(Command.R_HELO)
    void hello(HelloReply reply)
    {
        writeln("client hello " , getTid());
        writeln(reply.message);
    }

    @route(Command.Q_HEART)
    void heart()
    {
        writeln("client heart " , getTid());
        writeln("recv heart");
    }
}





int main()
{
    auto app = new Application();

    auto server = app.createServer("127.0.0.1" , 3003);
    auto client = app.createClient("127.0.0.1" , 3003 , "client");

    client.setOpenHandler((Context context){
        auto hello = new HelloRequest();
        hello.name = "world";
        context.sendMessage(Command.Q_HEART);
        context.sendMessage(Command.Q_HELO , hello);
        context.sendMessage(Command.Q_HEART);
    });

    app.run();  
    return 0;
}