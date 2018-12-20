module hunt.imf.io.server;

import hunt.net;

import hunt.imf.core.dispatcher;
import hunt.imf.protocol.parser;
import hunt.imf.protocol.packet;
import hunt.imf.io.context;



class Server
{
    this(Dispatcher dispatcher , string ns = "")
    {
        _namespace = ns;
        _dispatcher = dispatcher;
        _server = NetUtil.createNetServer!(ServerThreadMode.Single)();
    }

    void listen(int port , string host = "127.0.0.1")
    {
        alias Server = hunt.net.Server.Server;
        _server.listen(host , port , (Result!Server result){
            if(result.failed())
                throw result.cause();

        });
        _server.connectionHandler((NetSocket sock){
            auto tcp = cast(AsynchronousTcpSession)sock;
            auto context = new Context(_namespace , sock);
            tcp.attachObject(context);
            if(_open !is null){
                _open(context);
            }
            sock.closeHandler((){
                if(_close !is null)
                    _close(context);
            });
            sock.handler(
                (in ubyte[] data){
                    auto context = cast(Context)tcp.getAttachment();
                    auto list = context.parser.consume(cast(byte[])data);
                    foreach(p ; list)
                        _dispatcher.dispatch(context , p);
                }
            );
        });
    }

    void stop() {
        _server.stop();
    }

    void setOpenHandler(OpenHandler handler)
    {
        _open = handler;
    }

    void setCloseHandler(CloseHandler handler){
        _close = handler;
    }


private:
    string             _namespace;
    Dispatcher         _dispatcher;
    AbstractServer     _server;
    OpenHandler        _open;
    CloseHandler       _close;
}