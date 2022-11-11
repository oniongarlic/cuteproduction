import QtQuick 2.15
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtMultimedia 5.12

Popup {
    id: resolutionPopup
    modal: true
    width: parent.width/1.5
    height: parent.height/1.5

    function getResolutionText(w,h) {
        var m=Math.floor(w*h/1000/1000);
        if (m>0) {
            return w + " x " + h + " " + m + "Mbit"
        } else {
            return w + " x " + h
        }
    }

    property alias model: resolutionList.model

    signal cameraResolutionSelected(string res)

    ListView {
        id: resolutionList
        anchors.fill: parent
        clip: true
        // model: camera.imageCapture.supportedResolutions
        ScrollIndicator.vertical: ScrollIndicator { }
        delegate: Text {
            color: resma.pressed ? "#101060" : "#000000"
            text: resolutionPopup.getResolutionText(modelData.width, modelData.height)
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
                id: resma
                anchors.fill: parent
                onClicked: {
                    console.debug(modelData)
                    cameraResolutionSelected(modelData)
                    // camera.imageCapture.resolution=modelData
                    resolutionPopup.close();
                }
            }
        }
    }
}
