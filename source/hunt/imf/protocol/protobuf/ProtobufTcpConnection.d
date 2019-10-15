module hunt.imf.protocol.protobuf.ProtobufTcpConnection;

import hunt.net;
import hunt.imf.ConnectBase;
import hunt.imf.EvBuffer;
import hunt.String;
import hunt.imf.MessageBuffer;
import std.stdio;
import google.protobuf;
import std.array;

class ProtobufTcpConnection : ConnectBase {

private {
    Connection _conn = null;
}
public:

    this(Connection connection)
    {
        _conn = connection;
    }

    void onConnectionClosed()
    {
        _conn = null;
    }

    override void sendMsg(MessageBuffer message)
    {
        if (_conn.isConnected())
        {
            _conn.write(message);
        }
    }

    override Connection getConnection()
    {
        return _conn;
    }

    override string getProtocol()
    {
        return (cast(String)_conn.getAttribute(SESSION.PROTOCOL)).value;
    }

    override void close()
    {
        if (_conn !is null && _conn.getState() !is ConnectionState.Closed)
        {
            _conn.close();
        }
    }

    override bool isConnected()
    {
         return _conn.isConnected();
    }
}