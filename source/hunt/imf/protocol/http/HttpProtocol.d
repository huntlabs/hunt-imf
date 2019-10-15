module hunt.imf.protocol.http.HttpProtocol;

import hunt.imf.protocol.Protocol;
import hunt.net.codec.Codec;
import hunt.imf.ConnectionEventBaseHandler;
import hunt.imf.protocol.http.HttpConnectionEventHandler;
import hunt.imf.protocol.http.HttpCodec;
import hunt.imf.GatewayApplication;
import hunt.net.NetServerOptions;
import hunt.imf.ConnectionManager;
import hunt.net;

class HttpProtocol : Protocol
{
    private {
        string _host;
        ushort _port;
        enum string _name = typeof(this).stringof;
        ConnectionEventBaseHandler _handler;
        NetServerOptions _options = null;
        Codec _codec;
    }

    this(string host , ushort port)
    {
        _host = host;
        _port = port;
        _handler = new HttpConnectionEventHandler();
        _codec = new HttpCodec();
    }

    override void registerHandler()
    {
        GatewayApplication.instance().registerConnectionManager(_name);
        ConnectionManager!int manager = GatewayApplication.instance().getConnectionManager(_name);
        _handler.setOnConnection(&manager.onConnection);
    }

    void setCodec(Codec codec) {
        _codec = codec;
    }

    void setConnectionEventHandler(ConnectionEventBaseHandler handler)
    {
        _handler = handler;
    }

    override NetServerOptions getOptions()
    {
        return _options;
    }

    override string getName() {return _name;}

    override ushort getPort() {return _port;}

    override ConnectionEventHandler getHandler() {return _handler;}

    override Codec getCodec() {return _codec;}

    override string getHost() {return _host;}
}
