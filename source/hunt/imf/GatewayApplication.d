module hunt.imf.GatewayApplication;

import hunt.net;
import hunt.imf.protocol.Protocol;
import hunt.imf.ConnectionEventBaseHandler;
import hunt.imf.ConnectionManager;
import std.typecons;

class GatewayApplication
{
   private {
        NetServer[string] _servers;
        Protocol[string] _protocols;
        ConnectionManager!int[string] _mapConnManager;
        __gshared GatewayApplication _app = null;
   }

    private
    {
        this () {
        }
    }

    static GatewayApplication instance()
    {
        if (_app is null)
            _app = new GatewayApplication();
        return _app;
    }

    NetServer[string] getServers(){
        return _servers;
    }


    public void addServer(Protocol protocol)
    {
        protocol.registerHandler();
        _protocols[protocol.getName()] = protocol;
    }


    void registerConnectionManager(string protocolName)
    {
        if (protocolName in _mapConnManager)
        {
            return;
        }else
        {
            ConnectionManager!int manager = new ConnectionManager!int();
            _mapConnManager[protocolName] = manager;
        }
    }

    ConnectionManager!int getConnectionManager(string protocolName)
    {
        return _mapConnManager.get(protocolName,null);
    }


    void run()
    {
        foreach(protocol;_protocols)
        {
            NetServer server = NetUtil.createNetServer!(ThreadMode.Single)();
            server.setCodec(protocol.getCodec());
            server.setHandler(protocol.getHandler());
            if (protocol.getOptions() !is null)
            {
                server.setOptions(protocol.getOptions());
            }
            server.listen(protocol.getHost() ,protocol.getPort());
            _servers[protocol.getName()] = server;
        }
    }
}
