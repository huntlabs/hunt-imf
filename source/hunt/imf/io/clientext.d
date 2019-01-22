module hunt.imf.io.clientext;

import hunt.logging;

import hunt.imf.io.client;
import hunt.imf.core.dispatcher;
import hunt.imf.protocol.parser;
import hunt.imf.protocol.packet;
import hunt.imf.io.context;

import hunt.event.timer;
import hunt.util.Timer;
import hunt.net.NetUtil;

import core.time;

///
class ClientExt : Client
{
    OpenHandler     _openHandler;
    CloseHandler    _closeHandler;
    Timer           _timer;
    string          _host;
    int             _port;

    ///
    this(Dispatcher dispatcher , string ns = "")
    {
        super(dispatcher , ns);
    }

    ///
    override void connect(int port , string host = "127.0.0.1")
    {
        _host = host;
        _port = port;

        super.connect(port , host);
        super.setOpenHandler(&openHandler);
        super.setCloseHandler(&closeHandler);
    }

    override void setOpenHandler(OpenHandler handler)
    {
        _openHandler = handler;
    }

    override void setCloseHandler(CloseHandler handler){
        _closeHandler = handler;
    }

    private void onTick(Object sender)
    {
        logWarning("reconnecting " , _host , " " , _port);
        connect(_port , _host);
    }

    private void openHandler(Context context)
    {
        if(_openHandler !is null)
        {
            _openHandler(context);
        }

        //remove timer
        if(_timer !is null)
        {
            _timer.stop();
            _timer = null;
        }
    }

    private void closeHandler(Context context)
    {
        if(_closeHandler !is null)
        {
            _closeHandler(context);
        }
        if(_timer is null)
        {   
            _timer =  new Timer(NetUtil.defaultEventLoopGroup().nextLoop(), 3.seconds);
            _timer.onTick(&onTick);
            _timer.start();
        }
       
    }



}