import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.12
import QtQuick.Dialogs 1.3

import "../components"

Drawer {
    id: clapperDrawer
    dragMargin: 0
    width: parent.width/1.5
    height: parent.height

    property Clapper clapper;

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 8

        Switch {
            id: telepromptMsgSwitch
            Layout.alignment: Qt.AlignLeft
            text: "Display clapper/slate"
            checked: false
            onCheckedChanged: {
                clapper.visible=checked
            }
        }

        TextField {
            id: production
            Layout.fillWidth: true
            selectByMouse: true
            placeholderText: "Production"
            onAccepted: {
                clapper.production=text;
            }
        }
        TextField {
            id: director
            Layout.fillWidth: true
            selectByMouse: true
            placeholderText: "Director"
            onAccepted: {
                clapper.director=text;
            }
        }
        TextField {
            id: camera
            Layout.fillWidth: true
            selectByMouse: true
            placeholderText: "Camera"
            onAccepted: {
                clapper.camera=text;
            }
        }
        TextField {
            id: note
            Layout.fillWidth: true
            selectByMouse: true
            placeholderText: "Note"
            onAccepted: {
                clapper.note=text;
            }
        }
        RowLayout {
            SpinBox {
                from: 1
                value: 1
                to: 999
                editable: true
                onValueModified: {
                    clapper.roll=value
                }
            }
            SpinBox {
                from: 1
                value: 1
                to: 999
                editable: true
                onValueModified: {
                    clapper.scene=value
                }

            }
            SpinBox {
                from: 1
                value: 1
                to: 999
                editable: true
                onValueModified: {
                    clapper.take=value
                }
            }
        }

    }

}
