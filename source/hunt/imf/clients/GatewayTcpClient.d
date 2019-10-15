module hunt.imf.clients.GatewayTcpClient;

import hunt.imf.clients.GatewayClient;
import hunt.imf.protocol.Protocol;
import hunt.imf.ConnectBase;
import hunt.imf.protocol.protobuf.ProtobufTcpConnection;
import hunt.imf.ConnectionEventBaseHandler;
import hunt.imf.protocol.protobuf.TcpConnectionEventHandler;
import hunt.imf.MessageBuffer;
import google.protobuf;
import std.array;
import hunt.net;
import core.thread;
import core.sync.condition;
import core.sync.mutex;

class GatewayTcpClient : GatewayClient{

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
        _protocol = protocol;
    }

    void onConnection (ConnectBase connection)
    {
        _condition.mutex().lock();
        _conn = connection;
        _condition.notify();
        _condition.mutex().unlock();
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

    void sendMsg(T)(int tid,T t)
    {
        if (_conn !is null)
        {
            MessageBuffer ask =  new MessageBuffer(tid,t.toProtobuf.array);
            _conn.sendMsg(ask);
        }
    }

    void onClosed (ConnectBase connection)
    {

    }
}

