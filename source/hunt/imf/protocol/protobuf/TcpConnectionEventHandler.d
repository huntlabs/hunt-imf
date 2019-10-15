module hunt.imf.protocol.protobuf.TcpConnectionEventHandler;

import hunt.net;
import hunt.imf.protocol.protobuf.ProtobufTcpConnection;
import hunt.imf.ConnectionEventBaseHandler;
import hunt.imf.ConnectBase;
import hunt.imf.MessageBuffer;
import hunt.String;
import std.stdio;

class TcpConnectionEventHandler : ConnectionEventBaseHandler
{
    //alias ConnCallBack = void delegate(ConnectBase connection);
    //alias MsgCallBack = void delegate(Connection connection ,Object message);

    this(string attribute){
        _attribute = attribute;
    }

    override
    void connectionOpened(Connection connection)
    {
        if (_onConnection !is null)
        {
            connection.setAttribute(SESSION.PROTOCOL,new String(_attribute));
            ProtobufTcpConnection conn = new ProtobufTcpConnection(connection);
            _onConnection(conn);
        }
    }

    override
    void connectionClosed(Connection connection)
    {
        connection.setState(ConnectionState.Closed);
        if (_onClosed !is null )
        {
            ProtobufTcpConnection conn = new ProtobufTcpConnection(connection);
            _onClosed(conn);
        }
    }

    override
    void messageReceived(Connection connection, Object message)
    {
        MessageBuffer msg = cast(MessageBuffer)message;
        ConnectBase.dispatchMessage(new ProtobufTcpConnection(connection),msg);
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
    string _attribute = null;
    ConnCallBack _onConnection = null;
    ConnCallBack _onClosed = null;
    MsgCallBack _onMessage = null;
}

}

