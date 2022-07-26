import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.12

import ".."

Window {
    id: teleWindow
    title: "Teleprompt"
    minimumWidth: 800
    minimumHeight: 480
    width: 1024
    height: 720
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

    onClosing: {
        close.accepted=false;
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
        anchors.margins: 64

        TelepromptScroller {
            id: teleprompt
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: telepromptShow.checked
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
        text: countdownTimer.count
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
        property int count: 0
        onTriggered: {
            count--
            if (count==0) {
                countdownTimer.stop();
                teleprompt.start()
            }
        }

        function startCountdown() {
            count=countdownSeconds;
            countdownTimer.start()
        }
    }

    function telepromptStart() {
        if (countdownSeconds>0)
            countdownTimer.startCountdown()
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
