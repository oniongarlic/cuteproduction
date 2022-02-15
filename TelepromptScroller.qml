import QtQuick 2.15
import QtQuick.Controls 2.15

Flickable {
    id: sv    
    boundsBehavior: Flickable.StopAtBounds
    interactive: !timerScroll.running
    topMargin: 64
    bottomMargin: 64
    leftMargin: 8
    rightMargin: 8
    contentHeight: txt.height
    pixelAligned: false
    clip: true

    property bool mirror: true
    property bool flip: false

    property int scrollType: 0

    property alias running: timerScroll.running

    property alias text: txt.text

    property real scrollSpeed: 1
    property int scrollSpeedSeconds: txt.lineCount/0.8

    property int countDownSeconds: 4

    property int countDown: 4

    ScrollBar.vertical: ScrollBar {
        policy: ScrollBar.AlwaysOn
    }

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
        sv.contentY=topMargin;
    }
    function restart() {
        reset();
        start();
    }
    function setPosition(pos) {
        sv.contentY=pos;
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
    readonly property real relpos: scrollPosition/(svanim.to+topMargin)
    readonly property int positionSeconds: Math.round(scrollSpeedSeconds*relpos)

    onPositionSecondsChanged: console.debug("SECPOS:"+positionSeconds)        

    NumberAnimation {
        id: svanim
        target: sv
        property: "contentY"
        duration: scrollSpeedSeconds*1000
        from: -topMargin
        to: sv.contentHeight
        easing.type: Easing.Linear
    }

    Text {
        id: txt
        width: sv.width
        color: "white"
        text: ""
        font.pointSize: 32
        wrapMode: Text.WordWrap
        topPadding: 32
        leftPadding: 16
        rightPadding: 32
        bottomPadding: 16
        transform: Scale {
            origin.x: txt.width/2
            origin.y: txt.height/2
            xScale: sv.mirror ? -1 : 1
            yScale: sv.flip ? -1 : 1
        }
    }
}

