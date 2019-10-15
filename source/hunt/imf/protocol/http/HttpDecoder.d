module hunt.imf.protocol.http.HttpDecoder;

import hunt.net.codec.Decoder;
import hunt.collection.ByteBuffer;
import hunt.collection.BufferUtils;
import hunt.net.Connection;
import hunt.imf.ParserBase;

import hunt.imf.EvBuffer;


class HttpDecoder : ParserBase , Decoder {

    this() {

    }

    override void decode(ByteBuffer buf, Connection connection)
    {
        EvBuffer!ubyte revbuferr = getContext(connection);
        parserHttpStream(revbuferr,cast(ubyte[])buf.getRemaining(),connection);
    }

    private EvBuffer!ubyte getContext(Connection connection) {
        EvBuffer!ubyte revbuferr = null;
        revbuferr = cast(EvBuffer!ubyte) connection.getAttribute(CONTEXT);

        if (revbuferr is null) {
            revbuferr = new EvBuffer!ubyte ;
            connection.setAttribute(CONTEXT, revbuferr);
        }
        return revbuferr;
    }
}

