import QtQuick 2.15
import QtMultimedia 5.15

VideoOutput {
    id: vo
    x: 0
    y: 0
    width: parent.width
    height: parent.height
    fillMode: VideoOutput.PreserveAspectFit
    autoOrientation: true;        

    property Rectangle borderRect: mediaBorder

    property rect pos: Qt.rect(0, 0, 1, 1)

    onPosChanged: updatePosition();
    onWidthChanged: updatePosition();
    onHeightChanged: updatePosition();

    function updatePosition() {
        x=pos.x*vo.parent.width;
        y=pos.y*vo.parent.height;
        width=pos.width*vo.parent.width;
        height=pos.height*vo.parent.height;
    }

    function setMediaPosition(r) {
        pos=r;
    }

    function resetSize() {
        pos=Qt.rect(0, 0, 1, 1);
    }

    Rectangle {
        id: mediaBorder
        border.color: "#ffffff"
        border.width: 1
        color: "transparent"
        anchors.fill: parent
    }
}
