module hunt.imf.Command;

import hunt.net;
import hunt.imf.ConnectBase;
import hunt.imf.MessageBuffer;
import hunt.imf.Router;

interface Command {
     void execute (ConnectBase connection,MessageBuffer message);
}