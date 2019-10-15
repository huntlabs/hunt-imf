module hunt.imf.protocol.http.HttpCodec;


import hunt.net.codec.Codec;
import hunt.net.codec.Encoder;
import hunt.net.codec.Decoder;
import hunt.imf.protocol.http.HttpDecoder;
import hunt.imf.protocol.http.HttpEncoder;

class HttpCodec : Codec{

    private HttpEncoder _encoder;
    private HttpDecoder _decoder;

    this() {
        _encoder = new HttpEncoder();
        _decoder = new HttpDecoder();
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

