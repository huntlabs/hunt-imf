module hunt.imf.protocol.protobuf.ProtobufProtocol;

import hunt.imf.protocol.Protocol;
import hunt.net.codec.Codec;
import hunt.imf.ConnectionEventBaseHandler;

import hunt.imf.protocol.protobuf.TcpConnectionEventHandler;
import hunt.imf.protocol.protobuf.ProtobufCodec;
import hunt.imf.GatewayApplication;
import hunt.net.NetServerOptions;
import hunt.imf.ConnectionManager;
import hunt.imf.ConnectBase;
import hunt.net;

class ProtobufProtocol : Protocol {

    alias CloseCallBack = void delegate(ConnectBase connection);

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
        _handler = new TcpConnectionEventHandler(_name);
        _codec = new ProtobufCodec();
    }

    override void registerHandler()
    {
        GatewayApplication.instance().registerConnectionManager(_name);
        ConnectionManager!int manager = GatewayApplication.instance().getConnectionManager(_name);
        _handler.setOnConnection(&manager.onConnection);
        _handler.setOnClosed(&manager.onClosed);
    }

    void setDisConnectHandler (CloseCallBack handler)
    {
        GatewayApplication.instance().registerConnectionManager(_name);
        ConnectionManager!int manager = GatewayApplication.instance().getConnectionManager(_name);
        if (manager !is null )
        {
            manager.setCloseHandler(handler);
        }
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
