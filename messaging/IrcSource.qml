import QtQuick 2.15
import Communi 3.0

Item {
    id: ircSource

    function connect() {
        ircConnection.open()
    }

    Irc {
        id: irc
    }

    IrcConnection {
        id: ircConnection
        host: "localhost"
        nickName: "CuteProd"
        userName: "cuteprod"
        realName: "CuteProduction"
        port: 6667
        secure: false

        onConnected: {
            console.debug("IRC: Connected, joining channel")
            sendCommand(cmd.createJoin("#turku"))
        }

        onMessageReceived: {
            console.debug("IRC: Message")
            if (message.type === IrcMessage.Private) {
                console.debug(message.nick)
                console.debug(message.target)
                console.debug(message.private)
                console.debug(message.content)
                if (message.private)
                    l3window.addMessageLeft("", message.content);
                else
                    l3window.addMessageRight(message.nick, message.content);
            }
        }
    }

    IrcCommand {
        id: cmd
    }

    IrcBufferModel {
        id: ircBuffer
        sortMethod: Irc.SortByTitle
        connection: ircConnection
        onMessageIgnored: serverBuffer.receiveMessage(message)
    }

    IrcBuffer {
        id: serverBuffer
        sticky: true
        persistent: true
        name: connection.displayName
        Component.onCompleted: ircBuffer.add(serverBuffer)
    }
}
