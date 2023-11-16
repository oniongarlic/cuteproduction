import QtQuick
import QtQuick.Controls

Flickable {
    id: sv    
    boundsBehavior: Flickable.StopAtBounds
    interactive: !timerScroll.running    
    contentHeight: txt.height
    pixelAligned: false
    clip: true

    property bool mirror: false
    property bool flip: false

    property int scrollType: 0

    property bool running: timerScroll.running || svanim.running
    readonly property bool paused: svanim.paused

    property alias text: txt.text
    property alias fontSize: txt.font.pixelSize
    property alias textFormat: txt.textFormat

    property real scrollSpeed: 1
    property real lineSpeed: 0.6

    readonly property int scrollSpeedSeconds: (txt.lineCount/lineSpeed)*(1-relPos)
    readonly property real relPos: sv.contentY/sv.contentHeight

    property int seconds: 0

    Timer {
        id: scrollTicker
        interval: 1000
        repeat: true
        running: sv.running
        onTriggered: {
            seconds++
        }
    }

    ScrollBar.vertical: ScrollBar {
        parent: sv.parent
        anchors.top: sv.top
        anchors.bottom: sv.bottom
        anchors.left: sv.right
        anchors.leftMargin: 32
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
        seconds=0;
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
        id: timerScroll
        interval: 20
        repeat: true
        onTriggered: {
            sv.contentY+=scrollSpeed
        }
    }

    Timer {
        id: startDelay
        repeat: false
        interval: 1000
        onTriggered: startScroll()
    }

    property alias scrollPosition: sv.contentY
    readonly property real relpos: scrollPosition/(svanim.to+topMargin)
    readonly property int positionSeconds: Math.round(scrollSpeedSeconds*relpos)

    property double lineHeight: sv.contentHeight/(txt.lineCount+1)

    onLineHeightChanged: console.debug("LS:"+lineHeight)

    onPositionSecondsChanged: console.debug("SECPOS:"+positionSeconds)

    NumberAnimation {
        id: svanim
        target: sv
        property: "contentY"
        duration: scrollSpeedSeconds*1000
        from: sv.contentY
        to: sv.contentHeight
        easing.type: Easing.Linear
    }

    Text {
        id: txt
        width: sv.width
        color: "white"
        text: ""
        font.pixelSize: 72
        wrapMode: Text.WordWrap
        topPadding: 32
        leftPadding: 32
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

