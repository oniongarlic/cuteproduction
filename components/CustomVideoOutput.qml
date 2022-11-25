import QtQuick 2.15
import QtMultimedia

Item {
    id: voContainer
    anchors.fill: parent

    property alias vo: voi
    property alias fillMode: voi.fillMode
    property alias source: voi
    property Rectangle borderRect: mediaBorder

    property alias videoAngle: rotation.angle

    property bool animate: true
    property int animationDuration: 250
    property int behaviorDuration: animate ? animationDuration : 0

    onWidthChanged: {
        voi.updatePosition()
    }

    onHeightChanged: {
        voi.updatePosition()
    }

    function setMediaPosition(r) {
        voi.pos=r;
    }

    function setMediaAngle(a) {
        videoAngle=a;
    }

    VideoOutput {
        id: voi
        x: 0
        y: 0
        fillMode: VideoOutput.PreserveAspectFit
        // autoOrientation: true;

        property rect pos: Qt.rect(0, 0, 1, 1)

        Behavior on x { NumberAnimation { duration: behaviorDuration; easing.type: Easing.InOutCubic; } }
        Behavior on y { NumberAnimation { duration: behaviorDuration; easing.type: Easing.InOutCubic; } }
        Behavior on width { NumberAnimation { duration: behaviorDuration; easing.type: Easing.InOutCubic; } }
        Behavior on height { NumberAnimation { duration: behaviorDuration; easing.type: Easing.InOutCubic; } }

        onPosChanged: updatePosition();
        onParentChanged: updatePosition();

        Component.onCompleted: {
            resetSize();
            updatePosition();
        }

        function updatePosition() {
            x=pos.x*parent.width;
            y=pos.y*parent.height;
            width=pos.width*parent.width;
            height=pos.height*parent.height;
        }

        function resetSize() {
            pos=Qt.rect(0, 0, 1, 1);
        }

        Rectangle {
            id: mediaBorder
            border.color: "#ffffff"
            border.width: 1
            color: "transparent"
            antialiasing: true
            visible: false
            anchors.fill: parent
        }

        transform: Rotation {
            id: rotation
            origin.x: voi.width/2
            origin.y: voi.height/2
            axis.x: 0
            axis.y: 1
            axis.z: 0
            angle: 0

            Behavior on angle { NumberAnimation { duration: behaviorDuration; easing.type: Easing.InOutCubic; } }
        }
    }
}

