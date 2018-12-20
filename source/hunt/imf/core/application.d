module hunt.imf.core.application;

import hunt.imf.core.dispatcher;
import hunt.imf.io.server;
import hunt.imf.io.client;
import hunt.imf.io.context;

import hunt.net.NetUtil;

class Application
{

    this()
    {
        _dispatcher = new Dispatcher();
        
    }

    Server createServer(string host , int port ,  string namespace_="")
    {
        auto server = new Server(_dispatcher, namespace_);
        _servers ~= server;
        Addr addr = {host , port};
        _server_addrs ~= addr;
        return server;
    }

    Client createClient(string host , int port , string namespace_="")
    {
        auto client = new Client(_dispatcher ,namespace_ );
        _clients ~= client;
        Addr addr = {host , port};
        _client_addrs ~= addr;
        return client;
    }

    void run(long timeout = -1)
    {
        NetUtil.startEventLoop(timeout);
        _dispatcher.start();
        for(size_t i = 0 ; i < _servers.length ; i++)
            _servers[i].listen(_server_addrs[i].port , _server_addrs[i].host);   
        for(size_t i = 0 ; i < _clients.length ; i++)
            _clients[i].connect(_client_addrs[i].port , _client_addrs[i].host);
    }

    void stop() {
        NetUtil.stopEventLoop();
        _dispatcher.stop();
        
        for(size_t i = 0 ; i < _servers.length ; i++)
            _servers[i].stop();   
        for(size_t i = 0 ; i < _clients.length ; i++)
            _clients[i].stop();
    }


    private:

    Addr[]     _server_addrs;
    Addr[]     _client_addrs;
    Server[]   _servers;
    Client[]   _clients;
    Dispatcher _dispatcher;


    struct Addr
    {
        string host;
        int port;
    }
}
