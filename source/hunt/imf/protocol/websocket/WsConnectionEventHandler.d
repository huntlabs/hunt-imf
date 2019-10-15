module hunt.imf.protocol.websocket.WsConnectionEventHandler;

import hunt.imf.ConnectionEventBaseHandler;
import hunt.imf.ConnectBase;
import hunt.imf.MessageBuffer;
import hunt.http.server.WebSocketHandler;
import hunt.http.codec.http.model;
import hunt.http.codec.http.stream;
import hunt.http.codec.websocket.frame;
import hunt.http.codec.websocket.model;
import hunt.http.codec.websocket.stream.WebSocketConnection;
import hunt.http.codec.websocket.stream.IOState;
import hunt.imf.protocol.websocket.WsConnection;
import hunt.Byte;
import hunt.util.Serialize;
import hunt.String;
import hunt.logging;


class WsConnectionEventHandler : WebSocketHandler {

    alias ConnCallBack = void delegate(ConnectBase connection);
    alias CloseConnCallBack = void delegate(ConnectBase connection );
    alias MsgCallBack = void delegate(WebSocketConnection connection ,Frame message);

    this(string attribute)
    {
        _attribute = attribute;
    }

    override
    void onConnect(WebSocketConnection webSocketConnection) {
        import hunt.net.Connection;
        if (_onConnection !is null)
        {
            webSocketConnection.getTcpConnection.setAttribute(SESSION.PROTOCOL,new String(_attribute));
            WsConnection conn = new WsConnection(webSocketConnection);
            _onConnection(conn);
        }
        webSocketConnection.onClose((HttpConnection conn){
            conn.getTcpConnection().setState(ConnectionState.Closed);
            if (_onClosed !is null)
            {
                _onClosed(new WsConnection(webSocketConnection));
            }
        });
    }

    override
    void onError(Exception t, WebSocketConnection connection) {

    }

    override
    void onFrame(Frame frame, WebSocketConnection conn) {

        FrameType type = frame.getType();
        switch (type) {
            case FrameType.TEXT:
            {
                break;
            }
            case FrameType.BINARY:
            {
                BinaryFrame binFrame = cast(BinaryFrame) frame;
                ConnectBase.dispatchMessage(new WsConnection(conn),MessageBuffer.decode(cast(ubyte[])binFrame.getPayload().getRemaining()));
                break;
            }
            default:
                break;
        }
    }


    void setOnConnection(ConnCallBack callback)
    {
        _onConnection = callback;
    }


    void setOnClosed(CloseConnCallBack callback)
    {
        _onClosed = callback;
    }


    void setOnMessage(MsgCallBack callback)
    {
        _onMessage = callback;
    }

    private
    {
        string _attribute = null;
        ConnCallBack _onConnection = null;
        CloseConnCallBack _onClosed = null;
        MsgCallBack _onMessage = null;
    }
}

