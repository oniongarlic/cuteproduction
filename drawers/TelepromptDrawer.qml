import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.12
import QtQuick.Window 2.15
import QtQuick.Dialogs

import "../selectors"
import "../models"
import "../components"
import "../windows"

Drawer {
    id: telepromptDrawer
    dragMargin: 0
    width: parent.width/1.25
    height: parent.height

    property TelepromptWindow tpwindow;

    TextSelector {
        id: tsftp
        filter: [ "*.txt", "*.md" ]
        onFileSelected: {
            fr.read(src)
            if (src.endsWith('.md')) {
                telepromptFormat.checked=false
            }
            textPrompter.text=fr.data();
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 8

        ColumnLayout {
            id: telepromptItemMessage
            Layout.alignment: Qt.AlignTop
            Layout.fillHeight: true
            Layout.fillWidth: true

            ScrollView {
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.maximumHeight: telepromptDrawer.height/6
                ScrollBar.vertical.policy: ScrollBar.AlwaysOn
                background: Rectangle {
                    border.color: "black"
                    border.width: 1
                }
                TextArea {
                    id: telepromptTextMsg
                    placeholderText: "Write a telepromt message here"
                    selectByKeyboard: true
                    selectByMouse: true
                    textFormat: TextEdit.PlainText
                    wrapMode: TextEdit.Wrap
                }
            }
            RowLayout {
                Switch {
                    id: telepromptMsgSwitch
                    Layout.alignment: Qt.AlignLeft
                    text: "Display message"
                    checked: true
                    onCheckedChanged: {
                        if (checked)
                            tpwindow.setMessage(telepromptTextMsg.text)
                        else
                            tpwindow.setMessage("")
                    }
                }
                Button {
                    text: "Update"
                    enabled: telepromptMsgSwitch.checked && telepromptTextMsg.length>0
                    onClicked: {
                        tpwindow.setMessage(telepromptTextMsg.text)
                    }
                }
                Button {
                    text: "Send"
                    enabled: telepromptMsgSwitch.checked && telepromptTextMsg.length>0
                    onClicked: {
                        tpwindow.setMessage(telepromptTextMsg.text)
                        telepromptTextMsg.text=""
                    }
                }
                Button {
                    text: "Clear"
                    onClicked: {
                        tpwindow.setMessage("")
                    }
                }
            }
        }

        RowLayout {
            Switch {
                text: "Show window"
                checkable: true
                onCheckedChanged: {
                    tpwindow.visible=checked
                }
            }
            Switch {
                text: "Full screen"
                checkable: true
                enabled: tpwindow.visible
                checked: tpwindow.visibility==Window.FullScreen ? true : false
                onCheckedChanged: tpwindow.visibility=!checked ? Window.Windowed : Window.FullScreen
            }
            Button {
                text: "Load"
                enabled: true
                onClicked: tsftp.startSelector();
            }
            Button {
                text: "Paste"
                enabled: textPrompter.canPaste
                onClicked: {
                    textPrompter.paste()
                    tpwindow.telepromptSetText(textPrompter.text)
                }
            }
        }

        ScrollView {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.minimumHeight: telepromptDrawer.height/3
            Layout.maximumHeight: telepromptDrawer.height/2
            ScrollBar.vertical.policy: ScrollBar.AlwaysOn
            background: Rectangle {
                border.color: "black"
                border.width: 1
            }
            TextArea {
                id: textPrompter
                placeholderText: "Teleprompt text here"
                selectByKeyboard: true
                selectByMouse: true
                textFormat: TextEdit.PlainText
                wrapMode: TextEdit.WordWrap
            }
        }

        RowLayout {
            spacing: 8
            Switch {
                id: telepromptMirror
                Layout.alignment: Qt.AlignLeft
                text: "Mirror"
                onCheckedChanged: {
                    tpwindow.mirror=checked                    
                }
            }
            Switch {
                id: telepromptFlip
                Layout.alignment: Qt.AlignLeft
                text: "Flip"
                onCheckedChanged: {
                    tpwindow.flip=checked                    
                }
            }
            Switch {
                id: telepromptFormat
                Layout.alignment: Qt.AlignLeft
                text: "Plain"
                checked: true
                onCheckedChanged: {
                    tpwindow.textFormat=checked ? Text.PlainText : Text.MarkdownText
                }
            }
            SpinBox {
                id: lineSpeed
                from: 1
                to: 12
                stepSize: 1
                value: settings.getSettingsInt("telepromt/speed", 8, 1, 12)
                onValueChanged: {
                    settings.setSettings("teleprompt/speed", value)
                    if (!tpwindow)
                        return
                    tpwindow.lineSpeed=value/10.0
                }
                wheelEnabled: true
            }
            SpinBox {
                from: 16
                to: 128
                editable: true
                value: settings.getSettingsInt("telepromt/fontsize", 64, 16, 128)
                onValueChanged: {
                    settings.setSettings("teleprompt/fontsize", value)
                    if (!tpwindow)
                        return
                    tpwindow.fontSize=value;

                }
                wheelEnabled: true
            }
            SpinBox {
                from: 0
                to: 8
                value: settings.getSettingsInt("telepromt/countdown", 4, 0, 8)
                onValueChanged: {
                    settings.setSettings("teleprompt/countdown", value)
                    if (!tpwindow)
                        return
                    tpwindow.countdownSeconds=value;
                }
                wheelEnabled: true
            }
        }

        RowLayout {
            spacing: 8
            Button {
                text: "Update"
                onClicked: {
                    tpwindow.telepromptSetText(textPrompter.text)
                }
            }
            Button {
                text: "Start"
                enabled: !tpwindow.active
                onClicked: {
                    tpwindow.telepromptStart();
                }
            }
            Button {
                text: "Stop"
                enabled: tpwindow.active
                onClicked: {
                    tpwindow.telepromptStop();
                }
            }
            Button {
                text: "Pause"
                enabled: tpwindow.active && !tpwindow.paused
                onClicked: {
                    tpwindow.telepromptPause();
                }
            }
            Button {
                text: "Resume"
                enabled: tpwindow.active && tpwindow.paused
                onClicked: {
                    tpwindow.telepromptResume();
                }
            }
            Button {
                text: "Reset"
                enabled: tpwindow.active
                onClicked: {
                    tpwindow.telepromptStop();
                }
            }
            Text {
                text: tpwindow.position+" %"
            }
        }

        Slider {
            Layout.fillWidth: true
            id: telePromptPos
            from: 0
            to: tpwindow.promptHeight
            value: tpwindow.promptPos
            onValueChanged: {
                if (pressed) {
                    tpwindow.telepromptSetPosition(value)
                }
            }
        }
    }
}
