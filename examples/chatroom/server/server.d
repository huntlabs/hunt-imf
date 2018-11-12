module chatroom.server.server;

import hunt.imf;

import chatroom.command;
import chatroom.chatroom;

import std.stdio;
import std.string;




class UserInfo : Element
{
    this(Context context , string username)
    {
        super(context);
        this.username = username;
    }
    string username;
}

alias ChatRoom = Singleton!(Room!(string,UserInfo));

class ChatService
{
    mixin MakeRouter;

    @route(Command.MESSAGE)
    void recv(Msg message)
    {
        ChatRoom.instance.broadCast(Command.MESSAGE , message);
    }

    @route(Command.Q_LOGIN)
    void mylogin(Login login)
    {  
        ChatRoom.instance.findEx(login.name , 
            (UserInfo info){
            if(info is null)
            {
                auto user = new UserInfo(context , login.name);
                ChatRoom.instance.add(login.name, user);

                /// notify onlines this one login , except this one.
                ChatRoom.instance.broadCast(Command.LOGIN , login , login.name);

                /// rely to this one login suc. 
                auto reply = new LoginReply();
                reply.status = LoginReply.LoginState.OK;
                reply.name = login.name;
                context.sendMessage(Command.R_LOGIN , reply);

                /// set context bind
                context.setAttachment(user);

                writeln(login.name , " login");
                bSuc = true;
            }
            else
            {
                auto reply = new LoginReply();
                reply.name = login.name;
                reply.status = LoginReply.LoginState.FAIL;
                sendMessage(context , Command.R_LOGIN , reply);
            }
        });

      
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
            /// clear attach
            context.setAttachment(null);
            
            auto login = new Login();
            login.name = user.username;

            /// remove from chatroom
            ChatRoom.instance.remove(login.name);

            /// notify to all users
            ChatRoom.instance.broadCast(Command.LOGOUT,login);
            
            writeln(user.username ~ " logout");
        }
    });
    app.run();
    return 0;
}