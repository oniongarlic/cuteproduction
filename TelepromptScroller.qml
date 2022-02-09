import QtQuick 2.12

Flickable {
    id: sv    
    boundsBehavior: Flickable.StopAtBounds
    interactive: !timerScroll.running
    contentHeight: txt.height
    clip: true

    property bool mirror: true
    property bool flip: false

    property int scrollType: 0

    property alias running: timerScroll.running

    property alias text: txt.text

    property real scrollSpeed: 1
    property int scrollSpeedSeconds: 60

    property int countDownSeconds: 4

    property int countDown: 4

    function start() {
        startScroll();
    }

    function startCountdown() {

    }

    function startScroll() {
        if (scrollType==1)
            timerScroll.start()
        else
            svanim.start()
    }
    function stop() {
        timerScroll.stop()
        svanim.stop()
    }
    function pause() {
        if (scrollType==1)
            timerScroll.stop()
        else
            svanim.pause()
    }
    function resume() {
        if (scrollType==1)
            timerScroll.start()
        else
            svanim.resume()
    }
    function reset() {
        sv.contentY=0;
    }
    function restart() {
        reset();
        start();
    }

    Timer {
        id: countDownTimer
        onTriggered: {

        }
    }

    Timer {
        id: timerScroll
        interval: 20
        repeat: true
        onTriggered: {
            sv.contentY+=scrollSpeed
        }
    }

    property alias scrollPosition: sv.contentY

    NumberAnimation {
        id: svanim
        target: sv
        property: "contentY"
        duration: scrollSpeedSeconds*1000
        from: 0
        to: sv.contentHeight
        easing.type: Easing.Linear
    }

    Text {
        id: txt
        width: sv.width
        color: "white"
        text: "Sometimes, a font will apply complex rules to a set of characters in order to display them correctly.

In some writing systems, such as Brahmic scripts, this is required in order for the text to be legible, but in e.g. Latin script, it is merely a cosmetic feature.

Setting the preferShaping property to false will disable all such features when they are not required, which will improve performance in most cases."
        minimumPointSize: 18
        fontSizeMode: Text.Fit
        font.pointSize: 32
        wrapMode: Text.WordWrap
        // transform: Matrix4x4 { matrix: Qt.matrix4x4(-1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1) }
        // transform:  Matrix4x4 { matrix: Qt.matrix4x4( txt.mirror ? -1 : 0, 0, 0, txt.width, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1) }

        transform: Scale {
            origin.x: txt.width/2
            origin.y: txt.height/2
            xScale: sv.mirror ? -1 : 1
            yScale: sv.flip ? -1 : 1
        }

        padding: 20
    }

}

