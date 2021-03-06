module hunt.imf.protocol.websocket.WsProtocol;

import hunt.imf.protocol.Protocol;
import hunt.net.codec.Codec;
import hunt.imf.ConnectionEventBaseHandler;
import hunt.http.server.HttpServerOptions;
import hunt.imf.protocol.websocket.WsConnectionEventHandler;
import hunt.http.HttpOptions;
import hunt.http.server.ServerHttpHandler;
import hunt.http.codec.http.stream;
import hunt.http.server.Http2ServerRequestHandler;
import hunt.http.server.ServerSessionListener;
import hunt.http.codec.http.model.MetaData;
import hunt.net.NetServerOptions;
import hunt.http.server.WebSocketHandler;
import hunt.http.server.HttpServerHandler;
import hunt.net.Connection;
import hunt.imf.ConnectionManager;
import hunt.imf.protocol.websocket.WsConnectionEventHandler;
import hunt.imf.protocol.websocket.WsCodec;
import hunt.imf.GatewayApplication;
import hunt.logging;
import hunt.imf.ConnectBase;

class WsProtocol : Protocol{

    alias CloseCallBack = void delegate(ConnectBase connection);

    private {
        string _host;
        ushort _port;
        enum string _name = typeof(this).stringof;
        ConnectionEventHandler _handler = null;
        NetServerOptions _options = null;
        ServerHttpHandler _serverHandler = null;
        ServerSessionListener _listener = null;
        WsConnectionEventHandler _eventHandler = null;
        HttpServerOptions _httpOptions = null;
        Codec _codec;
    }

    this(string host , ushort port)
    {
        _host = host;
        _port = port;
        _codec = new WsCodec();

        HttpServerOptions config = new HttpServerOptions();
        _options = config.getTcpConfiguration();
        if(_options is null ) {
            _options = new NetServerOptions();
            config.setTcpConfiguration(_options);
        }
        _httpOptions = config;
        _serverHandler = new class ServerHttpHandlerAdapter {
            override
            bool messageComplete(HttpRequest request, HttpResponse response,
            HttpOutputStream output,
            HttpConnection connection) {
                return true;
            }
        };
        _listener = new Http2ServerRequestHandler(_serverHandler);
        _eventHandler = new WsConnectionEventHandler(_name);
    }

    override void registerHandler()
    {
        GatewayApplication.instance().registerConnectionManager(_name);
        ConnectionManager!int manager = GatewayApplication.instance().getConnectionManager(_name);
        _eventHandler.setOnConnection(&manager.onConnection);
        _eventHandler.setOnClosed(&manager.onClosed);
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

    override NetServerOptions getOptions()
    {
        return _options;
    }

    override string getName() {return _name;}

    override ushort getPort() {return _port;}

    override ConnectionEventHandler getHandler()
    {
        if (_handler is null)
        {
            _handler = new HttpServerHandler(_httpOptions, _listener,_serverHandler, _eventHandler);
        }
        return _handler;
    }

    override Codec getCodec() {return _codec;}

    override string getHost() {return _host;}
}
