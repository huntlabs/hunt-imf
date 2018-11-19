module hunt.imf.core.routing;

import std.traits;
import std.conv;
import std.stdint;


struct route
{
    int32_t cmd;
}

struct namespace
{
    string name;
}

alias VoidProcessFunc = void function(ubyte[]);
alias VoidProcessDele = void delegate(ubyte[]);

struct RouterData
{
    VoidProcessFunc func;
    string          className;
}

class Router
{
    __gshared static RouterData[int64_t][string] g_router;

    static void addRouter(string fullClassName , string ns , int64_t value, VoidProcessFunc func)
    {
        RouterData data;
        data.func = func;
        data.className = fullClassName;
        g_router[ns][value] = data;
    }

    static RouterData * findRouter( string ns , int64_t value)
    {
        auto updata = ns in g_router;
        if(updata == null)
            return null;
        auto data = value in g_router[ns];
        return data;
    }
}

mixin template MakeRouter(string moduleName = __MODULE__)
{
    mixin("import google.protobuf;");
    mixin(__MakeRouter0!(typeof(this)));
    mixin(__MakeRouter1!(typeof(this) , moduleName));
}


string __MakeRouter0(T)()
{
    string str;
    foreach (m; __traits(derivedMembers, T))
    {
        foreach( u ; getUDAs!(__traits(getMember , T , m) , route))
        {
            str ~= "void " ~ m ~ "_message(ubyte[] data){";
            alias classArr = Parameters!(__traits(getMember , T , m));
            static if (classArr.length == 0)
            {
                str ~= m ~ "();}";
            }
            else
            {   
                str ~= "auto proto = new " ~ classArr[0].stringof ~"();"; 
                str ~= "try{ data.fromProtobuf!"~classArr[0].stringof~"(proto); " ~m~ "(proto); }";
				str ~= "catch(Throwable e){ import hunt.logging;logError(e.msg);} }";
            }
        }   
    }
    return str;
}


string __MakeRouter1(T , string moduleName)()
{
    string ns = "";
    string str = "shared static this(){";
    
    foreach(n ; getSymbolsByUDA!(T,namespace))
    {
        if(n.stringof == T.stringof)
            ns = getUDAs!(n , namespace)[0].name;
    }

    foreach (m; __traits(derivedMembers, T))
    {
        foreach( u ; getUDAs!(__traits(getMember , T , m) , route))
        {
            str ~= "Router.addRouter(\""  ~ moduleName ~ "." ~ T.stringof ~ "\",\"" ~ ns ~"\" ,   " ~ to!string(u.cmd) ~ ",&" ~ T.stringof ~ "." ~ m ~ "_message);";
        }   
    }
    str ~= "}";  
    return str;  
}

