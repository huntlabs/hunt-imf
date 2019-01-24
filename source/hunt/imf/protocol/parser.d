module hunt.imf.protocol.parser;

import hunt.imf.protocol.packet;

import std.bitmanip;
import std.stdint;

class Parser
{
    ubyte[Packet.HEADERLEN]             headerbuffer;
    int32_t                             headerlen = 0;

    int32_t                             message_data_len;
    ubyte[]                             message_data;
    
   

    ///
    Packet[] consume(byte[] buffer)
    {
        Packet[] result;
        size_t length = buffer.length;
        size_t index = 0;
        size_t used;
        while(index < length)
        {
            /// in header.
            size_t left = length - index;
            if(headerlen < Packet.HEADERLEN)
            { 
                if(left >= Packet.HEADERLEN - headerlen)
                {
                    used = Packet.HEADERLEN - headerlen;
                    for(size_t i = 0 ; i < used ; i++)
                        headerbuffer[headerlen + i] = buffer[index + i];
                    index += used;
                    headerlen += used;
                    
                    message_data_len = bigEndianToNative!int32_t(headerbuffer[16 .. 20]);
                    message_data.length = 0;
                    
                    if(message_data_len == 0)
                    {
                        long message_id = bigEndianToNative!long(headerbuffer[8 .. 16]);
                        result ~= new Packet(message_id);
                        headerlen = 0;
                    }
                    
                }
                else
                {
                    for(size_t i = 0 ; i < left ; i++)
                        headerbuffer[headerlen + i] = buffer[index + i];
                    index += left;
                    headerlen += left;
                }
            }
            else
            {
                
                if( left >= message_data_len - message_data.length)
                {
                    long message_id = bigEndianToNative!long(headerbuffer[8 .. 16]);
                    used = message_data_len - message_data.length;
                    message_data ~= buffer[index .. index + used];
                    result ~= new Packet(message_id , message_data);
                    headerlen = 0;
                    index += used;
                }
                else
                {
                    message_data ~= buffer[index .. index + left];
                    index += left;
                }
            }
        }
        return result;
    }

}