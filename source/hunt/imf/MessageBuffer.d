module hunt.imf.MessageBuffer;

import hunt.logging;
import std.bitmanip;
import hunt.util.Serialize;
import std.stdint;

class MessageBuffer
{
    this(){
        authId = 0;
        messageId = -1;
        message = new ubyte[0];
    }

    this(long type,ubyte[] msgBody)
    {
        messageId = type;
        message = msgBody;
    }

    ubyte[] encode()
    {
        //ubyte[4] len = nativeToBigEndian(cast(int)message.length);
        //ubyte[] data = new ubyte[0];
        //data ~= cast(ubyte)messageId;
        //data ~= len;
        //data ~= message;
        //return data;
        ubyte[8] u1 = nativeToBigEndian(authId);
        ubyte[8] u2 = nativeToBigEndian(messageId);
        ubyte[4] u3 = nativeToBigEndian(cast(int32_t)message.length);

        return u1 ~ u2 ~ u3 ~ message;
    }

    static MessageBuffer decode(ubyte[] buff)
    {
        if (buff.length >= 20)
        {
            return new MessageBuffer(bigEndianToNative!long(buff[8 .. 16]),buff[20..$]);
        } else
            return null;
    }

    long     authId;
    long     messageId;
    ubyte[]  message;
}