import QtQuick
import Communi

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

    property alias connection: ircConnection

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

    signal connected()
    signal disconnected()

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
            ircSource.connected()
            if (ircSource.channel.length>0)
                sendCommand(cmd.createJoin(channel, channelKey))
        }

        onDisconnected: {
            console.debug("IRC: Disconnected")
            ircSource.disconnected()
        }

        onMessageReceived: (message) => {
            console.debug("IRC: Message: "+message.type)
            if (message.type === IrcMessage.Private) {
                var cmd=incomingParser.parse(message)
                if (cmd) {

                }

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
        onMessageIgnored: (message) => serverBuffer.receiveMessage(message)
    }

    IrcBuffer {
        id: serverBuffer
        sticky: true
        persistent: true
        name: ircConnection.displayName
        Component.onCompleted: ircBuffer.add(serverBuffer)
    }

    function sendMessage(msg) {
        var c = parser.parse(msg)
        if (c) {
            ircConnection.sendCommand(c)
        }
    }

    // Incoming messages
    IrcCommandParser {
        id: incomingParser
        channels: ircBuffer.channels
        triggers: ircConnection.network.isChannel(target) ? ["!", ircConnection.nickName + ":"] : ["!", ""]
        Component.onCompleted: {

        }
    }

    // Outgoing messages
    IrcCommandParser {
        id: parser
        tolerant: true
        channels: ircBuffer.channels
        //triggers: ircConnection.network.isChannel(target) ? ["!", ircConnection.nickName + ":"] : ["!", ""]
        triggers: ["/"]
        Component.onCompleted: {
            parser.addCommand(IrcCommand.Join, "JOIN <#channel> (<key>)");
            parser.addCommand(IrcCommand.Part, "PART (<#channel>) (<message...>)");
            parser.addCommand(IrcCommand.Kick, "KICK (<#channel>) <nick> (<reason...>)");
            parser.addCommand(IrcCommand.CtcpAction, "ME [target] <message...>");
        }
    }    
}
