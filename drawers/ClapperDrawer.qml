import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

import "../components"

Drawer {
    id: clapperDrawer
    dragMargin: 0
    width: parent.width/1.25
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
            checked: clapper.visible
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
            Layout.fillWidth: true
            spacing: 16
            Label {
                text: "Roll"
            }
            SpinBox {
                from: 1
                value: 1
                to: 999
                editable: true
                onValueModified: {
                    clapper.roll=value
                }                
            }
            Label {
                text: "Scene"
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
            Label {
                text: "Take"
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
