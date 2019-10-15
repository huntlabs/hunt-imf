module hunt.imf.ConnectionEventBaseHandler;

import hunt.net;
import hunt.imf.ConnectBase;

class ConnectionEventBaseHandler : ConnectionEventHandler
{
    alias ConnCallBack = void delegate( ConnectBase connection);
    alias MsgCallBack = void delegate(Connection connection ,Object message);

    override
    void connectionOpened(Connection connection) {}

    override
    void connectionClosed(Connection connection) {}

    override
    void messageReceived(Connection connection, Object message) {}

    override
    void exceptionCaught(Connection connection, Throwable t) {}

    override
    void failedOpeningConnection(int connectionId, Throwable t) { }

    override
    void failedAcceptingConnection(int connectionId, Throwable t) { }

    void setOnConnection(ConnCallBack callback)
    {
    }

    void setOnClosed(ConnCallBack callback)
    {
    }

    void setOnMessage(MsgCallBack callback)
    {
    }
}