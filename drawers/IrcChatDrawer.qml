import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Communi

import "../selectors"
import "../models"
import "../components"
import "../messaging"

Drawer {
    id: ircDrawer
    dragMargin: 0
    width: parent.width/1.25
    height: parent.height

    property IrcSource ircSource;

    //ircSource.channel: ircChannel.text
    //ircSource.channelKey: ircChannelKey.text
    //ircSource.host: ircHostname.text
    //ircSource.nickName: ircNick.text
    //ircSource.password: ircPassword.text
    //ircSource.secure: ircSecure.checked

    Connections {
        //target: ircSource.
    }

    Connections {
        target: ircSource.connection
        onMessageReceived: (message) => {
            switch (message.type) {
            case IrcMessage.Private:
                var line = message.nick+' '+message.target+' : '+message.content
                ircChat.append(line)
                break;
            case IrcMessage.Notice:
                ircChat.append(message.content)
                break;
            case IrcMessage.Motd:

                break;
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 8
        GridLayout {
            columns: 3
            enabled: !irc.connected
            TextField {
                id: ircHostname
                Layout.fillWidth: true
                placeholderText: "Hostname"
                selectByMouse: true
                text: ircSource.host
            }
            Switch {
                id: ircSecure
                text: "Secure connection"
                checked: false
            }
            TextField {
                id: ircPassword
                Layout.fillWidth: true
                placeholderText: "Password"
                selectByMouse: true
                text: ircSource.password
            }
            TextField {
                id: ircNick
                Layout.fillWidth: true
                placeholderText: "Nick"
                selectByMouse: true
                text: ircSource.nickName
            }
            TextField {
                id: ircRealname
                Layout.fillWidth: true
                placeholderText: "Real name"
                selectByMouse: true
                text: ircS
            }
            TextField {
                id: ircChannel
                Layout.fillWidth: true
                placeholderText: "Channel"
                selectByMouse: true
            }
            TextField {
                id: ircChannelKey
                Layout.fillWidth: true
                placeholderText: "Channel key"
                selectByMouse: true
            }
        }
        RowLayout {
            Layout.fillWidth: true
            Button {
                text: "Connect"
                enabled: !irc.connected && ircHostname.length>1
                onClicked: {
                    irc.connect();
                }
            }
            Button {
                text: "Disconnect"
                enabled: irc.connected
                onClicked: {
                    irc.disconnect();
                }
            }
        }
        Frame {
            visible: true
            Layout.fillHeight: true
            Layout.fillWidth: true
            ColumnLayout {
                anchors.fill: parent
                spacing: 4
                Label {
                    id: channelTopic
                    text: ""
                }
                SplitView {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    ListView {
                        id: channel
                        SplitView.minimumWidth: 80
                        SplitView.maximumWidth: 200
                        model: irc.channelModel
                        delegate: ItemDelegate {
                            text: model.title
                            width: parent.width
                            onClicked: {

                            }
                        }
                        Rectangle {
                            border.color: "#000"
                            border.width: 2
                            color: "transparent"
                            anchors.fill: parent
                        }
                        ScrollIndicator.vertical: ScrollIndicator { }
                    }
                    ScrollView {
                        SplitView.fillWidth: true
                        TextArea {
                            id: ircChat
                            readOnly: true
                            textFormat: Qt.RichText
                        }
                    }
                    ListView {
                        id: users
                        SplitView.fillWidth: false
                        SplitView.minimumWidth: 80
                        SplitView.maximumWidth: 200
                        model: irc.userModel
                        delegate: ItemDelegate {
                            text: model.title
                            onClicked: {

                            }
                        }
                        Rectangle {
                            border.color: "#000"
                            border.width: 2
                            color: "transparent"
                            anchors.fill: parent
                        }
                        ScrollIndicator.vertical: ScrollIndicator { }
                    }
                }
                RowLayout {
                    TextField {
                        id: ircText
                        Layout.fillWidth: true
                        onAccepted: {
                            ircSource.sendMessage(text)
                            ircText.clear()
                        }
                    }
                    Button {
                        text: "Send"
                        onClicked: {
                            ircSource.sendMessage(ircText.text)
                            ircText.clear()
                        }
                    }
                }
            }
        }
    }
}
