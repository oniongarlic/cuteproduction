import QtQuick 2.15
import Communi 3.0

Item {
    id: ircSource

    property alias host: ircConnection.host
    property alias nickName: ircConnection.nickName
    property alias userName: ircConnection.userName
    property alias realName: ircConnection.realName
    property alias port: ircConnection.port
    property alias secure: ircConnection.secure
    property alias password: ircConnection.password

    property alias connected: ircConnection.connected

    property string channel;
    property string channelKey;

    property IrcBufferModel channelModel: ircBuffer
    property IrcUserModel userModel: ircUserModel

    function connect() {
        ircConnection.open()
    }

    function disconnect() {
        ircConnection.close();
    }

    function joinChannel(channel, key) {
        ircConnection.sendCommand(cmd.createJoin(channel, key))
    }

    Irc {
        id: irc
    }

    IrcUserModel {
        id: ircUserModel
        sortMethod: Irc.SortByTitle
        channel: ircChannel
        // onChannelChanged: listView.currentIndex = -1
    }

    IrcChannel {
        id: ircChannel
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
            console.debug("IRC: Connected")
            //connected=true;
            if (ircSource.channel.length>0)
                sendCommand(cmd.createJoin(channel, channelKey))
        }

        onDisconnected: {
            //connected=false;
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

    IrcCommandParser {
        id: parser
        channels: ircBuffer.channels
        triggers: ircConnection.network.isChannel(target) ? ["!", ircConnection.nickName + ":"] : ["!", ""]
        Component.onCompleted: {

        }
    }
}
