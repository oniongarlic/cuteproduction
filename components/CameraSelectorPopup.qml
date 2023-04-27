import QtQuick 2.15
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtMultimedia

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
        delegate: ItemDelegate {
            id: c
            text: modelData.displayName
            width: parent.width
            onClicked: {
                cameraSelected(modelData.deviceId)
                cameraPopup.close();
            }
        }
    }
}
