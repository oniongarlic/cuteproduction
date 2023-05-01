import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia

Popup {
    id: cameraPopup
    modal: true
    x: parent.width/6
    y: parent.width/4
    width: parent.width/1.5
    height: parent.height/3

    signal cameraSelected(int deviceIndex)

    property alias model: cameraList.model
    property alias currentItem: cameraList.currentItem

    ListView {
        id: cameraList
        anchors.fill: parent
        clip: true        
        ScrollIndicator.vertical: ScrollIndicator { }
        delegate: ItemDelegate {
            id: c
            text: model.description
            width: parent.width
            onClicked: {
                ListView.view.currentIndex=index;
                cameraSelected(index)
                cameraPopup.close();
            }
        }
    }
}
