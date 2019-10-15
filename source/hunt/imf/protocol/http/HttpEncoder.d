module hunt.imf.protocol.http.HttpEncoder;

import hunt.net.codec.Encoder;
import hunt.net.Connection;
import hunt.imf.ParserBase;
import hunt.imf.MessageBuffer;
import hunt.collection.ByteBuffer;
import hunt.collection.BufferUtils;
import hunt.Exceptions;
import std.bitmanip;
import hunt.util.Serialize;
import std.conv;
import std.stdio;
import std.format;
import std.array;
import std.uri;

class HttpEncoder : ParserBase , Encoder  {

    this() {
    }

    override void encode(Object message, Connection connection)
    {
        auto msg = cast(MessageBuffer)message;
        HttpContent  content= unserialize!HttpContent(cast(byte[])msg.message);
        content.headField[Field.CONTENTLENGTH] = to!string(content.body.length);
        auto appender = appender!string;
        appender.reserve(1024);
        if (content.path.length != 0)
        {
            appender.put(content.method);
            appender.put(" ");
            appender.put(generateUrl(content));
            appender.put(" HTTP/1.1");
            appender.put(LINEFEEDS);
            appender.put(generateHeadField(content));
        }
        else
        {
            appender.put("HTTP/1.1 ");
            appender.put(to!string(content.status));
            appender.put(LINEFEEDS);
            appender.put(generateHeadField(content));
        }
        appender.put(content.body);
      //  writefln(appender[]);
        connection.write(appender[]);
    }

    void setBufferSize(int size)
    {

    }

    string generateUrl(ref HttpContent content)
    {
        auto appender = appender!string;
        appender.reserve(1024);

        appender.put(content.path);
        if (content.parameters.length != 0)
        {
            appender.put("?");
        }
        bool begin = true;
        foreach (key ; content.parameters.keys)
        {
            if (begin)
            {
                begin = !begin;
            }
            else
            {
                appender.put("&");
            }

            appender.put(key);
            appender.put("=");
            appender.put(content.parameters[key]);
        }
        return encodeComponent(appender[]);
    }

    string generateHeadField (ref HttpContent content)
    {
        auto appender = appender!string;
        foreach (key ; content.headField.keys)
        {
            appender.put(key);
            appender.put(": ");
            appender.put(content.headField[key]);
            appender.put(LINEFEEDS);
        }
        appender.put(content.headField.length == 0?HTTPHEADEOF:LINEFEEDS);
        return appender[];
    }
}

