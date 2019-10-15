module command.SayHelloCommand;

import hunt.imf.Command;
import hunt.imf.ConnectBase;
import hunt.imf.MessageBuffer;
import common.helloworld;
import hunt.net;
import common.Commands;
import hunt.imf.Router;
import google.protobuf;
import hunt.logging;
import std.array;

class SayHelloCommand : Command {

    void execute (ConnectBase connection,MessageBuffer msg)
    {
        auto req = new HelloRequest();
        msg.message.fromProtobuf!HelloRequest(req);

        auto resp = new HelloReply();
        resp.message = "hello " ~ req.name;
        MessageBuffer answer = new MessageBuffer(Commands.SayHelloResp,resp.toProtobuf.array);
        connection.sendMsg(answer);
    }
}

shared static this () {
    Router.instance().registerProcessHandler!SayHelloCommand(Commands.SayHelloReq);
}