module hunt.imf.ConnectBase;
import std.bitmanip;
import hunt.net;
import hunt.imf.MessageBuffer;
import hunt.imf.Router;
import hunt.imf.ParserBase;
import hunt.util.Serialize;
import google.protobuf;
import std.stdint;
import hunt.imf.Command;
import hunt.logging;
import hunt.http.codec.websocket.frame;
import hunt.http.codec.websocket.stream.WebSocketConnection;


enum SESSION
{
    PROTOCOL = "PROTOCOL",
    USER = "USER"
}

class ConnectBase {

public:
    static void dispatchMessage(ConnectBase connection , MessageBuffer message )
    {
        Command handler =  Router.instance().getProcessHandler(message.messageId);
        if (handler !is null)
        {
            handler.execute(connection,message);
        } else {
            logError("Unknown msgType %d",message.messageId );
        }
    }

    abstract void sendMsg(MessageBuffer message) {}

    abstract string getProtocol() { return null;}

    abstract Connection getConnection() {return null;}

    abstract void close() {}

    abstract bool isConnected() {return false;}
}