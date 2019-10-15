module hunt.imf.protocol.protobuf.ProtobufCodec;

import hunt.net.codec.Codec;
import hunt.net.codec.Encoder;
import hunt.net.codec.Decoder;
import hunt.imf.protocol.protobuf.ProtobufDecoder;
import hunt.imf.protocol.protobuf.ProtobufEncoder;


class ProtobufCodec : Codec
{
    private ProtobufEncoder _encoder = null;
    private ProtobufDecoder _decoder = null;

    this() {
        _encoder = new ProtobufEncoder();
        _decoder = new ProtobufDecoder();
    }

    Encoder getEncoder()
    {
        return _encoder;
    }

    Decoder getDecoder()
    {
        return _decoder;
    }
}