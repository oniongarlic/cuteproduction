import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts

import ".."
import "../components"

Window {
    id: teleWindow
    title: "Teleprompt"
    minimumWidth: 800
    minimumHeight: 480
    width: 1024
    height: 720
    x: screen.virtualX
    y: screen.virtualY
    modality: Qt.NonModal
    transientParent: null
    color: "black"

    property alias promptPos: teleprompt.contentY
    property alias lineSpeed: teleprompt.lineSpeed
    readonly property alias promptHeight: teleprompt.contentHeight

    property int countdownSeconds: 4;

    property bool mirror: false
    property bool flip: false
    
    property alias fontSize: teleprompt.fontSize
    property alias textFormat: teleprompt.textFormat

    readonly property bool active: teleprompt.running || countdown.active
    readonly property alias paused: teleprompt.paused

    readonly property int position: Math.round(teleprompt.relPos*100)

    onClosing: (close) => {
        close.accepted=false;
    }

    function setMessage(msg) {
        msgText.text=msg;
    }        

    MouseArea {
        anchors.fill: parent
        onDoubleClicked: {
            teleWindow.visibility=Window.FullScreen
        }
        onClicked: {
            teleWindow.visibility=Window.Windowed
        }
    }

    ColumnLayout {
        id: cl
        anchors.fill: parent
        anchors.topMargin: 32
        anchors.bottomMargin: 32
        anchors.leftMargin: 32
        anchors.rightMargin: 32
        spacing: 8        

        Rectangle {
            id: msgContainer
            visible: msgText.text!=''
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 52
            Layout.maximumHeight: msgText.contentHeight
            color: "#292929"
            MessageText {
                id: msgText
                text: "Hello World"
                font.pixelSize: 42
                color: "#ffffff"
                width: parent.width
                height: parent.height
                Component.onCompleted: {
                    position.marginBottom=8;
                    position.marginTop=8
                }

            }
        }

        TelepromptScroller {
            id: teleprompt
            Layout.fillWidth: true
            Layout.fillHeight: true
            mirror: teleWindow.mirror
            flip: teleWindow.flip
        }

        RowLayout {
            id: tpStatusBar
            Slider {
                id: positionSlider
                Layout.fillWidth: true
                from: 0
                to: tpwindow.promptHeight
                value: tpwindow.promptPos
            }
        }
    }

    Timer {
        id: timerGeneric
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            updateCurrentTime();
            //updateCounter();
        }
    }

    function updateCurrentTime() {
        var date = new Date;
        timeCurrent.text=Qt.formatTime(date, "hh:mm:ss");
    }

    TimeText {
        id: timeCurrent
        visible: true
        font.pixelSize: 32
        Component.onCompleted: {
            position.marginBottom=8;
            position.setPosition(Qt.AlignLeft, Qt.AlignBottom)
        }
    }
    TimeText {
        id: timeCount
        visible: true
        font.pixelSize: 32
        text: formatSeconds(teleprompt.seconds)
        Component.onCompleted: {
            position.marginBottom=8;
            position.setPosition(Qt.AlignRight, Qt.AlignBottom)
        }
    }

    CountDown {
        id: countdown
        anchors.fill: parent
        flip: teleWindow.flip
        mirror: teleWindow.mirror
        countdownSeconds: teleWindow.countdownSeconds

        onCountDownExpired: {
            teleprompt.start()
        }
    }

    function telepromptStart() {
        if (countdownSeconds>0)
            countdown.start()
        else
            teleprompt.start()
    }
    function telepromptPause() {
        teleprompt.pause()
    }
    function telepromptResume() {
        teleprompt.resume()
    }
    function telepromptStop() {
        if (countdown.active)
            countdown.stop()
        teleprompt.stop()
    }
    function telepromptReset() {
        teleprompt.reset()
    }
    function telepromptSetText(txt) {
        teleprompt.text=txt;
    }
    function telepromptSetPosition(pos) {
        teleprompt.setPosition(pos)
    }
}
