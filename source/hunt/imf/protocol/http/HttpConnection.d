module hunt.imf.protocol.http.HttpConnection;

import hunt.net;
import hunt.imf.ConnectBase;
import hunt.imf.MessageBuffer;
import hunt.imf.EvBuffer;
import hunt.util.Serialize;

class HttpConnection : ConnectBase {

    private {
        Connection _conn = null;
    }
    this(Connection connection) {
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

    override string getProtocol(){
        return null;
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

