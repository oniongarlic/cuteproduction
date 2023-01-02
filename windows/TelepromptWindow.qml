import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.12

import ".."
import "../components"

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
