module hunt.imf.core.dispatcher;

import hunt.imf.io.context;
import hunt.imf.protocol.packet;
import hunt.imf.core.task;

import std.parallelism:totalCPUs;

class Dispatcher
{
    this(size_t num = totalCPUs)
    {
        for(size_t i = 0 ; i < num ; i++)
            _taskpool ~= new Task();
    }
    
    void start()
    {
        foreach(t ; _taskpool)
            t.start();
        
        /// for dlang bug.
        import core.thread;
        import core.time;
        Thread.sleep(dur!"nsecs"(1));
    }

    void stop()
    {
        foreach(t ; _taskpool)
        {
            t.stop();
            t.join();
        }
    }

    void dispatch(Context context , Packet packet)
    {
        size_t index = context.toHash() % _taskpool.length;
        packet.setAttachment(context);
        _taskpool[index].push(packet);
    }
    private:
    
    Task[] _taskpool;
}

