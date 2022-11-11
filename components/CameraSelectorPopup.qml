import QtQuick 2.15
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtMultimedia 5.12

Popup {
    id: cameraPopup
    modal: true
    x: parent.width/6
    y: parent.width/4
    width: parent.width/1.5
    height: parent.height/3

    signal cameraSelected(string id)

    ListView {
        id: cameraList
        anchors.fill: parent
        clip: true
        model: QtMultimedia.availableCameras
        ScrollIndicator.vertical: ScrollIndicator { }
        delegate: Text {
            id: c
            color: cmlma.pressed ? "#101060" : "#000000"
            text: modelData.displayName
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            font.pixelSize: 22
            leftPadding: 4
            rightPadding: 4
            topPadding: 8
            bottomPadding: 8
            width: parent.width
            MouseArea {
                id: cmlma
                anchors.fill: parent
                onClicked: {
                    console.debug(modelData.deviceId)
                    console.debug(modelData.displayName)
                    console.debug(modelData.position)
                    cameraSelected(modelData.deviceId)
                    cameraPopup.close();
                }
            }
        }
    }
}
