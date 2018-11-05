module hunt.imf.utils.room;
import hunt.imf.utils.element;
import std.traits;
import hunt.imf.io.context;

class Room(K = size_t , E = Element) if ( is(E == Element) ||  is(BaseClassesTuple!E[$-2] == Element) )
{
    bool exists(K key) const
    {
        return get(key) !is null;      
    }

    bool join(K key ,  E entity)
    {  
        synchronized(this)
        {
            if( key in _hash)
                return false;
            _hash[key] = entity;
            return true;
        }
    }

    bool remove(K key)
    {
        synchronized(this)
        {
            return _hash.remove(key);
        }
    }

    const (E) get(K key) const
    {
        synchronized(this)
        {
            auto e = key in _hash;
            if( e !is null)
                return cast(const)(*e);
            return null;
        }
    }

    void broadCast(C )(C c , K[] excepts...) const
    {
        synchronized(this)
        {
            import std.algorithm.searching; 
            foreach(k , ref v ; _hash)
            {
                if(find!(" a == b")(excepts , k).length == 0)
                    v.context.sendMessage( c);
            }
        }
    }

    void broadCast(C , T)(C c , T t ,  K[] excepts...) 
    {
        synchronized(this)
        {
            import std.algorithm.searching; 
            foreach(k , ref v ; _hash)
            {
                if(find!(" a == b")(excepts , k).length == 0)
                    v.context.sendMessage(c , t);
            }
        }
    }

    void traverse(void delegate(  K , const   E) dele) 
    {
        synchronized(this)
        {
            foreach(  k ,   v ; _hash)
            {
                dele(k , v);
            }   
        }
    }

    size_t length() const
    {
        synchronized(this)
        {
            return _hash.length;
        }
    }

    private:
         E[K] _hash;

}