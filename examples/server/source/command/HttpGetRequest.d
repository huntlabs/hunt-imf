module action.HttpGetRequest;

import common.Commands;
import hunt.imf.Router;
import hunt.imf.Command;
import hunt.imf.ConnectBase;
import hunt.imf.MessageBuffer;
import hunt.imf.ParserBase;
import hunt.util.Serialize;
import hunt.logging;
class HttpGetRequest : Command {
    void execute (ConnectBase connection,MessageBuffer msg)
     {
         HttpContent  content = unserialize!HttpContent(cast(byte[])msg.message);
         content.reset();
         content.status = 200;
         content.body = "hello world " ~ content.body;

         MessageBuffer anser = new MessageBuffer(-1,cast(ubyte[])serialize!HttpContent(content));
         connection.sendMsg(anser);
     }
}

shared static this () {
    Router.instance().registerProcessHandler!HttpGetRequest(cast(int)hashOf("/test"));
}
