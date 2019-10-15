module hunt.imf.clients.GatewayClient;

import hunt.imf.protocol.protobuf.ProtobufTcpConnection;
import hunt.imf.protocol.Protocol;
import hunt.net;
import std.typecons;
import hunt.imf.ConnectionEventBaseHandler;
import hunt.imf.protocol.protobuf.TcpConnectionEventHandler;
import core.thread;
import core.sync.condition;
import core.sync.mutex;
import hunt.imf.MessageBuffer;
import hunt.imf.ConnectBase;
import hunt.logging;

interface GatewayClient {

    void onConnection (ConnectBase connection);

    //void sendMsg(int tid,ubyte[] msg) ;

    void connect() ;

    void onClosed (ConnectBase connection);
}