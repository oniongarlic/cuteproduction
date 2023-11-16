import QtQuick

Item {
    id: countdown

    property int count: 0
    property int countdownSeconds: 4;

    property bool mirror: false
    property bool flip: false

    property alias active: countdownTimer.running

    signal countDownExpired

    Rectangle {
        id: countDownBackground
        anchors.fill: parent
        color: "blue"
        opacity: 0.7
        visible: countdownTimer.running
    }

    Text {
        id: countDownText
        anchors.centerIn: countDownBackground
        color: "white"
        font.pixelSize: 128
        text: countdown.count
        visible: countdownTimer.running
        transform: Scale {
            origin.x: countDownText.width/2
            origin.y: countDownText.height/2
            xScale: mirror ? -1 : 1
            yScale: flip ? -1 : 1
        }
    }

    Timer {
        id: countdownTimer
        interval: 1000
        repeat: true
        onTriggered: {
            count--
            if (count==0) {
                countdownTimer.stop();
                countDownExpired()
            }
        }
    }

    function reset() {
        count=countdownSeconds;
    }

    function start() {
        reset()
        countdownTimer.start()
    }

    function stop() {
        countdownTimer.stop()
    }

}
