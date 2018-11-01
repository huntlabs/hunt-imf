module hunt.imf.core.task;



import hunt.imf.protocol.packet;
import hunt.imf.core.routing;
import hunt.imf.io.context;

import std.stdio;
import std.conv;
import std.stdint;
import std.container : DList;

import core.thread;
import core.sync.condition;
import core.sync.mutex;

import hunt.net;

class Task : Thread
{
    this()
    {
        _flag = true;
        _condition = new Condition(new Mutex());
        super(&run);
    }

    void push( Packet packet)
    { 
        synchronized(this){
            _queue.insertBack(packet);
        }
        _condition.notify();
    }

    void stop()
    {
        _flag = false;
        _condition.notify();
    }

private:
    Packet pop()
    {
        synchronized(this){
            if(_queue.empty())
                return null;
            auto packet = _queue.front();
            _queue.removeFront();
            return packet;
        }
    }

    void execute(Packet packet)
    {   
        auto context = cast(Context)packet.getAttachment();   
        auto data = Router.findRouter(context.ns , packet.message_id);
        if( data is null)
        {
            writeln("can't found router " ~ to!string(packet.message_id));
            return ;
        }

        auto obj = Object.factory(data.className);
        if( obj is null)
        {
            writeln("can't create " , data.className);
            return;
        }

        VoidProcessDele dele;
        dele.ptr = cast(void*)obj;
        dele.funcptr = data.func;
        
        setContext(context);
        dele(packet.message_data);
    }

    void run()
    {
        while(_flag)
        {
            _condition.mutex().lock();
            _condition.wait();
            _condition.mutex().unlock();
            Packet packet = null;
            while((packet = pop()) !is null)
            {
                execute(packet);
            }
        }
    }

    bool                  _flag;
    Condition             _condition;
    DList!Packet          _queue;
}