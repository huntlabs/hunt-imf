module chatroom.server.server;

import hunt.imf;

import chatroom.command;
import chatroom.chatroom;

import std.stdio;
import std.string;

import hunt.util.thread;
import core.sync.mutex;



class UserInfo
{
    string name;
    this(string name)
    {
        this.name = name;
    }
}


class ChatInfo
{
    __gshared Context[string] list;
    __gshared Mutex _mutex;
    static Mutex mutex()
    {
        if(_mutex is null)
            _mutex = new Mutex();
        return _mutex;
    }
}


class ChatService
{
    mixin MakeRouter;

    @route(Command.MESSAGE)
    void recv(Msg message)
    {
        foreach( u ; ChatInfo.list)
        {
            sendMessage(u , Command.MESSAGE , message);
        }
    }

    @route(Command.Q_LOGIN)
    void mylogin(Login login)
    {
        ChatInfo.mutex.lock();

        auto user = login.name in ChatInfo.list;
        if( user == null)
        {
            foreach( u ; ChatInfo.list)
            {
                sendMessage(u , Command.LOGIN , login);
            }
            ChatInfo.list[login.name] = context;
            auto reply = new LoginReply();
             reply.status = LoginReply.LoginState.OK;
             reply.name = login.name;
            sendMessage(context , Command.R_LOGIN , reply);
            auto info = new UserInfo(login.name);
            context.setAttachment(info);
            writeln(login.name , " login");
        }
        else
        {
            auto reply = new LoginReply();
            reply.name = login.name;
            reply.status = LoginReply.LoginState.FAIL;
            sendMessage(context , Command.R_LOGIN , reply);
        }
        ChatInfo.mutex.unlock();
    }

}


int main()
{
    auto app = new Application();
  
    auto server = app.createServer("127.0.0.1" , 3003);
    server.setCloseHandler((Context context){
        auto user = cast(UserInfo)context.getAttachment();
        if( user !is null)
        {
            ChatInfo.mutex.lock();
            ChatInfo.list.remove(user.name);
            auto login = new Login();
            login.name = user.name;
            foreach(u ; ChatInfo.list)
            {
                sendMessage(u , Command.LOGOUT , login);
            }
            writeln(login.name , " logout");
            ChatInfo.mutex.unlock();
        }
    });
    app.run();
    return 0;
}