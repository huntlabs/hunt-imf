module hunt.imf.io.client;

import hunt.collection.ByteBuffer;
import hunt.net;

import hunt.imf.core.dispatcher;
import hunt.imf.protocol.parser;
import hunt.imf.protocol.packet;
import hunt.imf.io.context;
import hunt.logging;

import std.socket;
import std.conv;

class Client
{
    this(Dispatcher dispatcher , string ns = "")
    {
        _dispatcher = dispatcher;
        _client = NetUtil.createNetClient();
        _namespace = ns;
    }

    void connect(int port , string host = "127.0.0.1")
    {
        string strPort = to!string(port);
		AddressInfo[] arr = getAddressInfo(host , strPort , AddressInfoFlags.CANONNAME);
		if(arr.length == 0 && arr[0].family == AF_INET)
		{
			throw new Exception("can't parse " ~ host ~ " or ipv6");
		}
    
        host = arr[0].address.toAddrString;
        
        _client.connect(port , host ,0, (Result!NetSocket result){
            if(result.failed())
            {
                logError(result.cause.msg);
                return;
            }
            auto tcp = cast(AsynchronousTcpSession)result.result();
            auto context = new Context(_namespace , tcp);
            tcp.attachObject(context);
            if(_open !is null)
                _open(context);

            tcp.closeHandler((){
                if(_close !is null)
                    _close(context);
            });
            tcp.handler((ByteBuffer buffer) {
                auto context = cast(Context)tcp.getAttachment();
                auto list = context.parser.consume(cast(byte[])buffer.getRemaining());
                foreach(p ; list)
                    _dispatcher.dispatch(context , p);
                });   
        });

    }

    void stop() {
        _client.stop();
    }

    void setOpenHandler(OpenHandler handler)
    {
        _open = handler;
    }

    void setCloseHandler(CloseHandler handler){
        _close = handler;
    }

protected:
    string          _namespace;
    Dispatcher      _dispatcher;
    NetClient       _client;
    OpenHandler     _open;
    CloseHandler    _close;
}