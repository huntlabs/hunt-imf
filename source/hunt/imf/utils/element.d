module hunt.imf.utils.element;
import hunt.imf.io.context;

class Element
{
    this(Context context)
    {
        _context = context;
    }

    Context context() @property
    {
        return _context;
    }

    private:
        Context _context;

}



unittest
{
    class E1 : Element
    {
        this(Context context)
        {
            super(context);
        }
    }

    class E2 : E1
    {
        this(Context context)
        {
            super(context);
        }
    }

    import hunt.imf.utils.room;
    import hunt.imf.utils.singleton;
    auto room = new Room!(size_t , Element)();
    auto room1 = new Room!(size_t , E1)();
    auto room2 = new Room!(size_t , E2)();

    import std.stdio;
    void test(string[] arg...)
    {
        
        writeln(arg.length);
    }

    writeln(Singleton!(Room!(size_t , Element)).instance().length);

    test("test");
    test(["test"]);
}