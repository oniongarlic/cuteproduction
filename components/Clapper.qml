import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    color: "black"

    property string production: ""
    property string director: ""
    property string camera: ""

    property string note: ""

    property string date: "01.01.2023"

    property int roll: 1
    property int scene: 1
    property int take: 1

    Component.onCompleted: {
        date=Qt.formatDateTime(new Date(), "dd.MM.yyyy")
    }

    ColumnLayout {
        id: cl
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16
        GroupBox {
            Layout.fillWidth: true
            Layout.fillHeight: false
            ColumnLayout {
                anchors.fill: parent
                spacing: 16
                TextTemplate {
                    text: "Production"
                    font.pixelSize: 28
                    Layout.fillWidth: true
                }
                TextTemplate {
                    id: textProduction
                    text: production
                    Layout.fillWidth: true
                    fontSizeMode: Text.Fit
                    wrapMode: Text.WordWrap
                    maximumLineCount: 2
                }
            }
        }
        RowLayout {
            id: rl
            spacing: 16
            Layout.fillWidth: true
            Layout.fillHeight: false
            ColumnLayout {
                TextTemplate {
                    text: "Roll"
                    font.pixelSize: 28
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                }
                TextTemplate {
                    id: textRoll
                    text: roll
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                    font.pixelSize: 64
                    fontSizeMode: Text.Fit
                }
            }
            ColumnLayout {
                TextTemplate {
                    text: "Scene"
                    font.pixelSize: 28
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                }
                TextTemplate {
                    id: textScene
                    text: scene
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                    font.pixelSize: 64
                    fontSizeMode: Text.Fit
                }
            }
            ColumnLayout {
                TextTemplate {
                    text: "Take"
                    font.pixelSize: 28
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                }
                TextTemplate {
                    id: textTake
                    text: take
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                    font.pixelSize: 64
                    fontSizeMode: Text.Fit
                }
            }
        }
        GridLayout {
            id: gl
            rows: 2
            columns: 2
            Layout.fillWidth: true
            columnSpacing: 16
            rowSpacing: 16
            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop
                Layout.maximumWidth: gl.width/2
                TextTemplate {
                    text: "Director"
                    font.pixelSize: 28
                    Layout.fillWidth: true
                }
                TextTemplate {
                    id: textDirector
                    text: director
                    font.pixelSize: 64
                    Layout.fillWidth: true
                    fontSizeMode: Text.Fit
                    wrapMode: Text.WordWrap
                    maximumLineCount: 2
                }
            }
            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop
                Layout.maximumWidth: gl.width/2
                TextTemplate {
                    text: "Camera"
                    font.pixelSize: 28
                    Layout.fillWidth: true
                }
                TextTemplate {
                    id: textCamera
                    text: camera
                    font.pixelSize: 64
                    Layout.fillWidth: true
                    fontSizeMode: Text.Fit
                    wrapMode: Text.WordWrap
                    maximumLineCount: 2
                }
            }
            ColumnLayout {
                Layout.fillWidth: false
                Layout.alignment: Qt.AlignTop
                TextTemplate {
                    text: "Date"
                    font.pixelSize: 28
                    Layout.fillWidth: true
                }
                TextTemplate {
                    id: textDate
                    text: date
                    font.pixelSize: 64
                    Layout.fillWidth: true
                    fontSizeMode: Text.Fit
                    wrapMode: Text.NoWrap
                }
            }
            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop
                visible: note!=''
                TextTemplate {
                    text: "Note"
                    font.pixelSize: 28
                    Layout.fillWidth: true
                }
                TextTemplate {
                    id: textNote
                    text: note
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    font.pixelSize: 64
                    fontSizeMode: Text.Fit
                    wrapMode: Text.WordWrap
                    maximumLineCount: 4
                }
            }
        }
    }
}
