import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.12
import QtQuick.XmlListModel 2.15
import QtQuick.Dialogs 1.3

import "../selectors"
import "../models"
import "../components"

Drawer {
    id: thirdsDrawer
    dragMargin: 0
    width: parent.width/1.25
    height: parent.height

    function clearL3Input() {
        textl3Primary.clear()
        textl3Secondary.clear()
        textl3Topic.clear()
    }

    Component {
        id: l3drawerDelegate
        ItemDelegate {
            id: l3id
            width: ListView.view.width
            height: r.height
            RowLayout {
                id: r
                width: parent.width
                ColumnLayout {
                    id: c
                    spacing: 4
                    Layout.fillWidth: true
                    Layout.preferredWidth: parent.width/1.5
                    Text { text: primary; font.bold: true; font.pixelSize: 14 }
                    Text { text: secondary; font.italic: true; font.pixelSize: 12 }
                    Text { text: topic; font.pixelSize: 12 }
                }
            }
            onClicked: {
                ListView.view.currentIndex=index;
            }
            onDoubleClicked: {
                ListView.view.currentIndex=index;
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 8
        TextField {
            id: textl3Primary
            Layout.fillWidth: true
            placeholderText: "Primary (name, etc)"
            selectByMouse: true
        }
        TextField {
            id: textl3Secondary
            Layout.fillWidth: true
            placeholderText: "Secondary (title, e-mail, etc)"
            selectByMouse: true
        }
        TextField {
            id: textl3Topic
            Layout.fillWidth: true
            placeholderText: "Topic/Keyword"
            selectByMouse: true
        }
        ListView {
            id: l3edit
            model: l3ModelFinal
            delegate: l3drawerDelegate
            clip: true
            Layout.fillWidth: true
            Layout.fillHeight: true
            highlight: Rectangle { color: "lightblue" }
            ScrollIndicator.vertical: ScrollIndicator {}
        }
        RowLayout {
            spacing: 8
            Button {
                text: "Add"
                onClicked: {
                    const item={
                        "primary": textl3Primary.text,
                        "secondary": textl3Secondary.text,
                        "topic": textl3Topic.text,
                        "image": ""}
                    l3ModelFinal.append(item)
                }
            }
            Button {
                text: "Clear input"
                onClicked: {
                    thirdsDrawer.clearL3Input();
                }
            }
            Button {
                text: "Close"
                onClicked: {
                    thirdsDrawer.close()
                }
            }
        }
    }
}
