import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../selectors"
import "../models"
import "../components"
import "../messaging"

Drawer {
    id: ircDrawer
    dragMargin: 0
    width: parent.width/1.25
    height: parent.height
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 8
        TextField {
            id: ircHostname
            Layout.fillWidth: true
            placeholderText: "Hostname"
            selectByMouse: true
        }
        TextField {
            id: ircPassword
            Layout.fillWidth: true
            placeholderText: "Password"
            selectByMouse: true
        }
        Switch {
            id: ircSecure
            text: "Secure connection"
            checked: false
        }
        TextField {
            id: ircNick
            Layout.fillWidth: true
            placeholderText: "Nick"
            selectByMouse: true
        }
        TextField {
            id: ircRealname
            Layout.fillWidth: true
            placeholderText: "Real name"
            selectByMouse: true
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
        RowLayout {
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
                    text: "Topic"
                }
                SplitView {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    ListView {
                        id: channel
                        SplitView.fillWidth: true
                        model: irc.channelModel
                        delegate: Label {
                            text: model.title
                        }
                    }
                    ListView {
                        id: users
                        SplitView.fillWidth: true
                        model: irc.userModel
                        delegate: Label {
                            text: model.title
                        }
                    }
                }
            }
        }
    }
}
