module hunt.imf.protocol.Protocol;

import hunt.net.codec.Codec;
import hunt.imf.ConnectionEventBaseHandler;
import hunt.net.NetServerOptions;
import hunt.net;
interface Protocol
{
    string getName();
    ushort getPort();
    string getHost();
    ConnectionEventHandler getHandler();
    Codec getCodec();
    NetServerOptions getOptions();
    void registerHandler();
}




