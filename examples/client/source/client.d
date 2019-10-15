import std.stdio;

import hunt.imf.protocol.Protocol;
import hunt.imf.protocol.protobuf.ProtobufProtocol;
import common.Commands;
import common.helloworld;
import google.protobuf;
import std.array;
import hunt.imf.clients.GatewayClient;
import hunt.imf.clients.GatewayWebSocketClient;
import hunt.imf.protocol.websocket.WsProtocol;
import hunt.imf.clients.GatewayHttpClient;
import hunt.imf.protocol.http.HttpProtocol;
import hunt.imf.clients.GatewayTcpClient;
import hunt.imf.ParserBase;
import core.thread;
import hunt.logging;
void main()
{
	auto req = new HelloRequest ();
	req.name = "1234567890abcdefjhijklmnopqrstuvwxyz";

    WsProtocol ws = new WsProtocol("127.0.0.1",18181);
	GatewayWebSocketClient wsclient = new GatewayWebSocketClient(ws);
	wsclient.connect();

	wsclient.sendMsg(Commands.SayHelloReq,req);

//-------------------------------------------------------------------

	ProtobufProtocol tcp = new ProtobufProtocol("127.0.0.1",12001);
	GatewayTcpClient tcpclient = new GatewayTcpClient(tcp);
	tcpclient.connect();

	tcpclient.sendMsg(Commands.SayHelloReq,req);

//----------------------------------------------------------------
	HttpProtocol http = new HttpProtocol("127.0.0.1",18080);
	GatewayHttpClient httpclient = new GatewayHttpClient(http);
	httpclient.connect();

	HttpContent content;
	content.path = "/test";
	content.parameters["a"] = "123";
	content.parameters["b"] = "456";
	content.method = "POST";
	content.body = "1234567890abcdefjhijklmnopqrstuvwxyz";
	httpclient.sendMsg(content);

	getchar();
}
