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
                text: "Clear"
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
