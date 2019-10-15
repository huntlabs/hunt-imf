module hunt.imf.clients.GatewayWebSocketClient;

import hunt.http.client.ClientHttpHandler;
import hunt.http.client.HttpClient;
import hunt.http.client.HttpClientConnection;
import hunt.http.client.HttpClientRequest;
import hunt.http.HttpOptions;
import hunt.http.HttpConnection;
import hunt.http.codec.http.stream.HttpOutputStream;
import hunt.http.codec.websocket.frame;
import hunt.http.codec.websocket.model.IncomingFrames;
import hunt.http.codec.websocket.stream.WebSocketConnection;
import hunt.http.codec.websocket.stream.WebSocketPolicy;
import hunt.concurrency.Promise;
import hunt.concurrency.Future;
import hunt.concurrency.FuturePromise;
import hunt.concurrency.CompletableFuture;
import hunt.http.client.HttpClientOptions;
import hunt.imf.clients.GatewayClient;
import hunt.imf.protocol.Protocol;
import google.protobuf;
import std.array;
import hunt.imf.ConnectBase;
import hunt.imf.protocol.websocket.WsConnection;
import hunt.net;
import hunt.logging;
import hunt.imf.MessageBuffer;

class ClientHttpHandlerEx : AbstractClientHttpHandler {
    import hunt.http.codec.http.model;

    override public bool messageComplete(HttpRequest request,
    HttpResponse response, HttpOutputStream output, HttpConnection connection) {
        tracef("upgrade websocket success: " ~ response.toString());
        return true;
    }
}

class IncomingFramesEx : IncomingFrames
{
    private
    {
        ConnectBase _conn;
    }

    void setWsConnection(ConnectBase connection)
    {
        _conn = connection;
    }

    override public void incomingError(Exception t) {
    }
    override public void incomingFrame(Frame frame) {
        FrameType type = frame.getType();
        switch (type) {
            case FrameType.TEXT:
            {
                break ;
            }
            case FrameType.BINARY:
            {
                BinaryFrame binFrame = cast(BinaryFrame) frame;
                ConnectBase.dispatchMessage( _conn,MessageBuffer.decode( cast(ubyte[])binFrame.getPayload().getRemaining()));
                break ;
            }
            default:
            break ;
        }
    }
}

class GatewayWebSocketClient : GatewayClient
{
    private
    {
        HttpClientConnection _connection;
        Protocol _protocol;
        HttpClientRequest _request;
        FuturePromise!WebSocketConnection _promise;
        IncomingFramesEx _incomingFramesEx;
        ClientHttpHandlerEx _handlerEx;
        ConnectBase _conn = null;
    }

    this(Protocol protocol)
    {
        _request = new HttpClientRequest("GET", "/index");
        _promise = new FuturePromise!WebSocketConnection();
        _incomingFramesEx = new IncomingFramesEx();
        _handlerEx = new ClientHttpHandlerEx();
        _protocol = protocol;
    }


    void connect()
    {
        HttpClient client = new HttpClient(new HttpClientOptions());
        Future!(HttpClientConnection) conn = client.connect(_protocol.getHost(), _protocol.getPort());
        _connection = conn.get();
        _connection.upgradeWebSocket(_request, WebSocketPolicy.newClientPolicy(),
        _promise, _handlerEx, _incomingFramesEx);
         WebSocketConnection connection = _promise.get();
        _conn = new WsConnection(connection);
        _incomingFramesEx.setWsConnection(_conn);
    }

    void sendMsg(T)(int tid,T t)
    {
        if (_conn !is null)
        {
            MessageBuffer ask = new MessageBuffer(tid,t.toProtobuf.array);
            _conn.sendMsg(ask);
        }
    }

    void onConnection (ConnectBase connection)
    {

    }

    void onClosed (ConnectBase connection)
    {

    }

}

