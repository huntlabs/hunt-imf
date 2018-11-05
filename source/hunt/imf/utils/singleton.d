module hunt.imf.utils.singleton;

import core.sync.mutex;

class Singleton(T)
{
    static T instance() @property
    {   
        __gshared T g_t;
        if(g_t is null)
        {
            synchronized
            {
                if(g_t is null)
                {
                    g_t = new T();
                }
            }
        }
        return g_t;
    }
    
}