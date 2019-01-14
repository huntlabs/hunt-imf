module chatroom.client.client;

import hunt.imf;

import chatroom.command;
import chatroom.chatroom;

import std.stdio;
import std.string;

import hunt.concurrency.thread;

class ClientInfo {
    __gshared string name;
    __gshared Context context;
}

class ClientService {
    mixin MakeRouter;

    @route(Command.MESSAGE)
    void recv(Msg message) {
        writeln(message.name, " : ", message.message);
    }

    @route(Command.R_LOGIN)
    void mylogin(LoginReply login) {
        ClientInfo.name = login.name;
        if (login.status == LoginReply.LoginState.OK)
            writeln("you have logined!");
        else
            writeln("username repeated! change username relogin please!");
    }

    @route(Command.LOGIN)
    void otherlogin(Login login) {
        writeln(login.name, " login");
    }

    @route(Command.LOGOUT)
    void otherlogout(Login login) {
        writeln(login.name, " logout");
    }

}

//////////////////////////////////------/////////////////////////////

void showHelp() {
    writeln("clientchat:");
    writeln("1 login username");
    writeln("2 send message");
    writeln("3 help");
    writeln("4 quit");
}

void showPromt() {
    write(">>>>");
}

void showError() {
    writeln("input error");
}

string login(string name) {
    auto login = new Login();
    login.name = name;
    sendMessage(ClientInfo.context, Command.Q_LOGIN, login);
    return name;
}

void send(string m) {
    auto msg = new Msg();
    msg.name = ClientInfo.name;
    msg.message = m;
    sendMessage(ClientInfo.context, Command.MESSAGE, msg);
}

int main() {
    string c;
    showHelp();
    showPromt();

    auto app = new Application();
    auto client = app.createClient("127.0.0.1", 3003);
    client.setOpenHandler((Context context) {
        writeln("connected to server!");
        ClientInfo.context = context;
    });
    app.run(50);

    while ((c = strip(readln())) != "quit") {
        string[] params = c.split(" ");
        if (params.length == 0) {
            showPromt();
            continue;
        }

        switch (params[0]) {
        case "help":
            showHelp();
            break;
        case "login":
            if (params.length < 2) {
                showError();
                continue;
            }
            login(params[1]);
            break;
        case "send":
            if (params.length < 2 || ClientInfo.name == string.init) {
                showError();
                continue;
            }
            send(params[1]);
            break;
        default:
            showHelp();
            break;

        }
        showPromt();
    }

    app.stop();
    // thread_joinAll();

    return 0;
}
