module hunt.imf.ConnectionManager;

import hunt.collection.HashMap;
import hunt.imf.ConnectBase;
import hunt.imf.protocol.protobuf.ProtobufTcpConnection;
import hunt.imf.protocol.http.HttpConnection;
import hunt.imf.protocol.websocket.WsConnection;
import hunt.imf.protocol.protobuf.TcpConnectionEventHandler;
import hunt.imf.protocol.http.HttpConnectionEventHandler;
import hunt.imf.protocol.websocket.WsConnectionEventHandler;
import hunt.http.codec.websocket.stream.WebSocketConnection;
import hunt.net;
import hunt.logging;
import std.conv : to;

class ConnectionManager(T) {

    alias CloseCallBack = void delegate(ConnectBase connection);

    private {
        HashMap!(T,ConnectBase) _mapConns;
        string _protocolName;
        CloseCallBack _onClosed = null;
    }

    this ()
    {
        _mapConns = new HashMap!(T,ConnectBase);
    }


    void onConnection ( ConnectBase connection)
    {
        synchronized(this)
        {
            trace("----------------put--%s",connection.getProtocol());
            _mapConns.put(connection.getConnection().getId().to!T,connection);
        }
    }

    void onClosed(ConnectBase connection)
    {
        if (_onClosed !is null)
        {
            _onClosed(connection);
        }
        synchronized(this){
            trace("----------------del--%s",connection.getProtocol());
            _mapConns.remove(connection.getConnection().getId().to!T);
        }
    }

    ConnectBase getConnection(T connId)
    {
        synchronized(this)
        {
           return  _mapConns.get(connId);
        }
    }

    void putConnection(T connId ,ConnectBase conn)
    {
        synchronized(this)
        {
            _mapConns.put(connId,conn);
        }
    }

    void removeConnection(T connId)
    {
        synchronized(this)
        {
            _mapConns.remove(connId);
        }
    }

    bool isExist(T connId)
    {
        HashMap!(T,ConnectBase) temp = null;
        synchronized(this)
        {
            temp = _mapConns;
        }
        return temp.containsKey(connId);
    }

    void setProtocolName(string name)
    {
        _protocolName = name;
    }

    string getProtocolName()
    {
        return _protocolName;
    }

    void setCloseHandler (CloseCallBack callback)
    {
        _onClosed = callback;
    }

}