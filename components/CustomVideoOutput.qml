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

    function setMediaPosition(r) {
        x=r.x*vo.parent.width;
        y=r.y*vo.parent.height;
        width=r.width*vo.parent.width;
        height=r.height*vo.parent.height;
    }

    function resetSize() {
        x=0;
        y=0;
        width=parent.width
        height=parent.height
    }

    Rectangle {
        id: mediaBorder
        border.color: "#ffffff"
        border.width: 1
        color: "transparent"
        anchors.fill: parent
    }
}
