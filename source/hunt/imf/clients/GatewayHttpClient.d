module hunt.imf.clients.GatewayHttpClient;

import hunt.imf.clients.GatewayClient;
import hunt.imf.protocol.Protocol;
import hunt.imf.ConnectBase;
import hunt.imf.ConnectionEventBaseHandler;
import hunt.imf.protocol.http.HttpConnection;
import hunt.imf.MessageBuffer;
import hunt.imf.ParserBase;
import hunt.util.Serialize;
import hunt.net;
import core.thread;
import core.sync.condition;
import core.sync.mutex;
import hunt.logging;

class GatewayHttpClient : GatewayClient {

    private {
        Condition _condition;
        ConnectBase _conn = null;
        Protocol _protocol;
        NetClient _netClient;
    }

    this(Protocol protocol) {
        _condition = new Condition(new Mutex());
        ConnectionEventBaseHandler handler = cast(ConnectionEventBaseHandler)protocol.getHandler();
        handler.setOnConnection(&this.onConnection);
        handler.setOnClosed(&this.onClosed);
        handler.setOnMessage(&this.onMessage);
        _protocol = protocol;
    }

    void onConnection (ConnectBase connection)
    {
        _condition.mutex().lock();
        _condition.notify();
        _condition.mutex().unlock();
         connection.getConnection().setAttribute("CLIENT");
        _conn = connection;
    }

    void connect()
    {
        NetClient client = NetUtil.createNetClient();
        client.setCodec(_protocol.getCodec());
        client.setHandler(_protocol.getHandler());
        client.connect(_protocol.getHost(),_protocol.getPort());
        _condition.mutex().lock();
        _condition.wait();
        _condition.mutex().unlock();
        _netClient = client;
    }

    void sendMsg(ref HttpContent content)
    {
        if (_conn !is null)
        {
            MessageBuffer ask = new MessageBuffer(0,cast(ubyte[])serialize!HttpContent(content));
            _conn.sendMsg(ask);
        }
    }


    void onMessage(Connection conneciton, Object message)
    {
        MessageBuffer msg = cast(MessageBuffer)message;
        HttpContent  content = unserialize!HttpContent(cast(byte[])msg.message);
        tracef("%s",content.body);
        conneciton.close();
    }

    void onClosed (ConnectBase connection)
    {

    }

}

