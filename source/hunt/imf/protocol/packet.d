module hunt.imf.protocol.packet;

import std.stdint;
import std.bitmanip;

class Packet
{
    enum    HEADERLEN = 20;
    long     auth_key_id = 0;
    long     message_id;
    int32_t     message_data_length;
    ubyte[]     message_data;
    Object      object;

    this(long message_id ,  ubyte[] message_data)
    {
        this.message_id = message_id;
        this.message_data_length = cast(int32_t)message_data.length;
        this.message_data = message_data;
    }

    this(long message_id)
    {
        this.message_id = message_id;
        this.message_data_length = 0;
    }

    ubyte[] data() @property 
    {
        ubyte[8] u1 = nativeToBigEndian(auth_key_id);
        ubyte[8] u2 = nativeToBigEndian(message_id);
        ubyte[4] u3 = nativeToBigEndian(message_data_length);

        return u1 ~ u2 ~ u3 ~ message_data;
    } 

    Object getAttachment() 
    {
        return object;
    }

    void setAttachment(Object attachment) 
    {
        object = attachment;
    }



}