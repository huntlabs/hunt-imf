module hunt.imf.io.context;

import hunt.net;


import hunt.imf.protocol.packet;
import hunt.imf.protocol.parser;

import google.protobuf;

import std.array;
import std.stdio;
import std.stdint;


class Context
{
    this(string ns , NetSocket sock)
    {
        _namespace = ns;
        _sock = sock;
        _parser = new Parser();
    }

    string ns() @property
    {
        return _namespace;
    }

    NetSocket sock() @property
    {
        return _sock;
    }

    Parser parser() @property
    {
        return _parser;
    }

    Object getAttachment() 
    {
        return object;
    }

    void setAttachment(Object attachment) 
    {
        object = attachment;
    }
    string      _namespace;
    NetSocket   _sock;
    Parser      _parser;
    
    
    Object      object;
}

alias OpenHandler = void delegate(Context context);
alias CloseHandler = void delegate(Context context);


static Context g_context;

Context context() @property
{
    return g_context;
}

void setContext(Context context)
{
    g_context = context;
}

void sendMessage(M)(Context context,int64_t message_id , M m)
{
    auto packet = new Packet(message_id ,  m.toProtobuf.array);
    auto data = packet.data;
    context.sock.write(packet.data);
}

void sendMessage(Context context,int64_t message_id)
{
    auto packet = new Packet(message_id);
    auto data = packet.data;
    context.sock.write(packet.data);
}

void close(Context context)
{
    context.sock.close();
}