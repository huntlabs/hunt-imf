module imf.io.server;

import hunt.net;

import imf.core.dispatcher;
import imf.protocol.parser;
import imf.protocol.packet;
import imf.io.context;



class Server
{
    this(Dispatcher dispatcher , string ns = "")
    {
        _namespace = ns;
        _dispatcher = dispatcher;
        _server = NetUtil.createNetServer();
    }

    void listen(int port , string host = "127.0.0.1")
    {
        _server.listen(port , host , (Result!NetServer result){
            if(result.failed())
                throw result.cause();

        }).connectHandler((NetSocket sock){
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

    void setOpenHandler(OpenHandler handler)
    {
        _open = handler;
    }

    void setCloseHandler(CloseHandler handler){
        _close = handler;
    }


private:
    string          _namespace;
    Dispatcher      _dispatcher;
    NetServer       _server;
    OpenHandler     _open;
    CloseHandler    _close;
}