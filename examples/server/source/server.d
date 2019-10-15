import std.stdio;
import hunt.net;
import hunt.logging;
import hunt.imf.protocol.protobuf.TcpConnectionEventHandler;
import hunt.imf.protocol.Protocol;
import hunt.imf.protocol.protobuf.ProtobufProtocol;
import hunt.imf.protocol.http.HttpProtocol;
import hunt.imf.GatewayApplication;
import hunt.imf.protocol.websocket.WsProtocol;
import core.thread;

void main()
{
	GatewayApplication app = GatewayApplication.instance();
	ProtobufProtocol tcp = new ProtobufProtocol("0.0.0.0",12001);
	HttpProtocol http = new HttpProtocol("0.0.0.0",18080);
	WsProtocol ws = new WsProtocol("0.0.0.0",18181);
	app.addServer(http);
	app.addServer(tcp);
	app.addServer(ws);
	app.run();
}
