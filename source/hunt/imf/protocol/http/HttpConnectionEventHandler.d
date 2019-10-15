module hunt.imf.protocol.http.HttpConnectionEventHandler;

import hunt.logging;
import hunt.net;
import hunt.imf.MessageBuffer;
import hunt.imf.ConnectBase;
import hunt.imf.protocol.http.HttpConnection;
import hunt.imf.ConnectionEventBaseHandler;

class HttpConnectionEventHandler : ConnectionEventBaseHandler {

    this() {
    }

    override
    void connectionOpened(Connection connection)
    {
        if (_onConnection !is null)
        {
           auto conn =  new HttpConnection(connection);
            _onConnection(conn);
        }
    }

    override
    void connectionClosed(Connection connection)
    {
        if (_onClosed !is null )
        {
            auto conn =  new HttpConnection(connection);
            _onClosed(conn);
        }
    }

    override
    void messageReceived(Connection connection, Object message)
    {
        MessageBuffer msg = cast(MessageBuffer)message;
        if (connection.getAttribute("CLIENT") !is null)
        {
            if (_onMessage !is null)
            {
                _onMessage(connection,message);
            }
        }
        else
        {
            ConnectBase.dispatchMessage(new HttpConnection(connection),msg);
        }
    }

    override
    void exceptionCaught(Connection connection, Throwable t)
    {

    }

    override
    void failedOpeningConnection(int connectionId, Throwable t) { }

    override
    void failedAcceptingConnection(int connectionId, Throwable t) { }

    override
    void setOnConnection(ConnCallBack callback)
    {
        _onConnection = callback;
    }

    override
    void setOnClosed(ConnCallBack callback)
    {
        _onClosed = callback;
    }

    override
    void setOnMessage(MsgCallBack callback)
    {
        _onMessage = callback;
    }

    private
    {
        string _tag = null;
        ConnCallBack _onConnection = null;
        ConnCallBack _onClosed = null;
        MsgCallBack _onMessage = null;
    }

}

