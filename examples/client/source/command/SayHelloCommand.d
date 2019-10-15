module command.SayHelloCommand;

import common.helloworld;
import hunt.imf.Command;
import hunt.net;
import hunt.imf.ConnectBase;
import hunt.imf.MessageBuffer;
import google.protobuf;
import hunt.imf.Router;
import common.Commands;
import std.array;
import std.stdio;

class SayHelloCommand : Command
{
    void execute (ConnectBase connection,MessageBuffer msg)
    {
        auto resp = new HelloReply();
        msg.message.fromProtobuf!HelloReply(resp);
        writefln("%s",resp.message);
    }
}

shared static this () {
    Router.instance().registerProcessHandler!SayHelloCommand(Commands.SayHelloResp);
}