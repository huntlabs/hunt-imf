module hunt.imf.utils.room;
import hunt.imf.utils.element;
import std.traits;
import hunt.imf.io.context;

class Room(K = size_t , E = Element) 
{
    bool exists(K key) 
    {
        synchronized(this)
        {
            auto e = key in _hash;
            if(e is null)
                return false;
            else
                return true;
        }
    }

    bool add(K key ,  E entity)
    {  
        synchronized(this)
        {
            if( key in _hash)
                return false;
            _hash[key] = entity;
            return true;
        }
    }

    void findEx(K key , void delegate(E e) dele)
    {
        synchronized(this)
        {
            auto e = key in _hash;
            if( e is null)
                dele(null);
            else
                dele(*e);
        }
    }

    bool remove(K key)
    {
        synchronized(this)
        {
            return _hash.remove(key);
        }
    }

    static if ( is(E == Element) ||  is(BaseClassesTuple!E[$-2] == Element)) 
    {
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
    }

    static if ( is(E == Element) ||  is(BaseClassesTuple!E[$-2] == Element))
    {
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