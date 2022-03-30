import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.15
import QtQuick.XmlListModel 2.15

import ".."
import "../animations"
import "../delegates"

Window {
    id: secondaryWindow
    title: "Information"
    minimumWidth: spanWindow ? Screen.desktopAvailableWidth : 800
    minimumHeight: spanWindow ? Screen.desktopAvailableHeight : 480
    width: 1024
    height: 720
    modality: Qt.NonModal
    transientParent: null
    color: bgBlack.checked ? "black" : bgGreen.checked ? "green" : "blue"

    property var startTime;

    property bool spanWindow: false;

    property bool tickerVisible: menuTickerVisible.checked;

    property ListModel newsTickerModel: tickerModel

    Component.onCompleted: {
        startTime=new Date()
    }

    onClosing: {
        close.accepted=false;
    }

    MouseArea {
        anchors.fill: parent
        onDoubleClicked: {
            secondaryWindow.visibility=Window.FullScreen
        }
        onClicked: {
            secondaryWindow.visibility=Window.Windowed
        }
    }

    LowerThirdBase {
        id: l3
        mainTitle: main.primary
        secondaryTitle: main.secondary
        displayTime: delayTime.value*1000
    }

    MessageListView {
        id: msgLeftBottom
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.top: parent.top

        model: msgModelLeft
        delegate: msgDelegate

        visible: switchMessageListLeft.checked
    }

    MessageListView {
        id: msgRightBottom
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.top: parent.top

        model: msgModelRight
        delegate: msgDelegate

        xpos: x+width+32

        visible: switchMessageListRight.checked
    }

    ListModel {
        id: msgModelLeft
    }
    ListModel {
        id: msgModelRight
    }

    ListModel {
        id: tickerModel
    }

    // Testing timer
    Timer {
        running: false
        repeat: true
        interval: 1800
        onTriggered: {
            var item={'primary': "Dynamic item: "+ new Date().toDateString(), 'secondary': new Date().toLocaleTimeString() }
            //msgModel.append(item)
            msgModel.insert(0, item)
            if (msgModel.count>5)
                msgModel.remove(5, 1)
        }
    }

    Timer {
        id: timerGeneric
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            updateCurrentTime();
            updateCounter();
        }
    }

    Timer {
        id: tickerTimer
        interval: 100
        running: newsTicker.visible && tickerList.count>1
        repeat: true

        property int ct: 100
        property int delay: 10

        onTriggered: {
            if (delay>0) {
                delay--;
                return;
            }

            ct--
            if (ct<5) {
                tickerMsg.opacity=0;
                tickerMsgContainer.opacity=1;
            }
            if (ct>1)
                return;

            ct=100;
            delay=10;

            if (tickerList.currentIndex<tickerList.count-1)
                tickerList.currentIndex++
            else
                tickerList.currentIndex=0
        }
    }


    function clearNews() {
        tickerModel.clear()
    }

    function addNewsItem(item) {
        tickerModel.append(item)
    }

    function show() {
        l3.show();
    }

    function setMessage(msg) {
        msgText.text=msg;
    }

    function updateCurrentTime() {
        var date = new Date;
        timeCurrent.text=Qt.formatTime(date, "hh:mm:ss");
    }

    function updateCounter() {

    }

    function timerStart() {
        timerGeneric.start()
    }

    function addMessage(p, s, m) {
        var item={'primary': p, 'secondary': s }
        m.insert(0, item)
        if (m.count>5)
            m.remove(5, 1)
    }

    function addMessageLeft(p, s) {
        addMessage(p, s, msgModelLeft)
    }
    function addMessageRight(p, s) {
        addMessage(p, s, msgModelRight)
    }
    function removeMessageLeft() {
        msgModelLeft.remove(msgModelLeft.count-1, 1)
    }
    function clearMessagesLeft() {
        msgModelLeft.clear()
    }
    function removeMessageRight() {
        msgModelRight.remove(msgModelRight.count-1, 1)
    }
    function clearMessagesRight() {
        msgModelRight.clear()
    }

    Component {
        id: msgDelegate
        MessageDelegate {

        }
    }

    ColumnLayout {
        id: cl
        anchors.fill: parent
        anchors.leftMargin: 32
        anchors.rightMargin: 32
        anchors.topMargin: 128
        anchors.bottomMargin: 128
        spacing: 16

        property real fontSizeRatioTime: 5

        Text {
            id: msgText
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop
            color: "#ffffff"
            text: ""
            styleColor: "#202020"
            style: Text.Outline
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: secondaryWindow.height/8
            visible: text!=""
            wrapMode: Text.WordWrap
            maximumLineCount: 4
        }
        Text {
            id: timeCurrent
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignCenter
            color: "#ffffff"
            text: ""
            font.family: "FreeSans"
            font.bold: true
            styleColor: "#202020"
            style: Text.Outline
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: secondaryWindow.height/cl.fontSizeRatioTime
            visible: showTime.checked
        }
        Text {
            id: timeCount
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignCenter
            color: "#ffffff"
            font.family: "FreeSans"
            font.bold: true
            styleColor: "#202020"
            style: Text.Outline
            text: formatSeconds(ticker.seconds)
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: secondaryWindow.height/cl.fontSizeRatioTime
            visible: showCounter.checked
        }
        Text {
            id: timeCountdown
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignCenter
            color: "#ffffff"
            font.family: "FreeSans"
            font.bold: true
            styleColor: "#202020"
            style: Text.Outline
            text: formatSeconds(ticker.countdown)
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: secondaryWindow.height/cl.fontSizeRatioTime
            visible: showCountdown.checked
        }
    }

    DropShadow {
        visible: false
        anchors.fill: cl
        horizontalOffset: 3
        verticalOffset: 3
        radius: 8.0
        samples: 17
        color: "#80000000"
        source: cl
    }

    ColumnLayout {
        id: newsTicker
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 32
        spacing: 0
        visible: tickerModel.count>0 && secondaryWindow.tickerVisible

        ListView {
            id: tickerList
            Layout.fillWidth: true
            Layout.margins: 0
            clip: true
            height: 48
            interactive: false
            orientation: ListView.Horizontal
            delegate: tickerDelegate
            model: tickerModel
            highlightFollowsCurrentItem: true
            highlight: tickerHighlight
            onCurrentIndexChanged: {
                console.debug("Tick: "+currentIndex)
                tickerMsg.text=tickerModel.get(currentIndex).msg
                tickerMsg.opacity=1
                tickerMsgContainer.opacity=1
            }
        }

        Rectangle {
            id: tickerDelayBar
            height: 8
            color: "red"
            width: (parent.width/100)*tickerTimer.ct
            opacity: tickerMsg.opacity
            Behavior on width { NumberAnimation { } }
            Behavior on opacity { NumberAnimation { } }
        }

        Rectangle {
            id: tickerMsgContainer
            height: tickerMsg.height
            Layout.fillWidth: true
            color: "#ffffff"
            Behavior on opacity { NumberAnimation { duration: 500 } }
            Text {
                id: tickerMsg
                color: "#292929"
                padding: 8
                maximumLineCount: secondaryWindow.width>1208 ? 1 : 2
                width: parent.width
                height: secondaryWindow.height>720 ? 48 : 86
                elide: Text.ElideRight
                font.pointSize: 24
                textFormat: Text.PlainText
                wrapMode: Text.Wrap
                text: ""
                Behavior on opacity { NumberAnimation { duration: 250 } }
            }
        }
    }

    //            DropShadow {
    //                enabled: false
    //                anchors.fill: newsTicker
    //                horizontalOffset: 3
    //                verticalOffset: 3
    //                radius: 8.0
    //                samples: 17
    //                color: "#80000000"
    //                source: newsTicker
    //            }


    Component {
        id: tickerHighlight
        Rectangle {
            color: "lightblue"
            Behavior on x {
                NumberAnimation { }
            }
        }
    }

    Component {
        id: tickerDelegate
        ItemDelegate {
            width: tickerList.width/4
            highlighted: ListView.isCurrentItem
            height: c.height
            background: Rectangle {
                color: highlighted ? "#ffffff" : "#a0a0a0"
                radius: 0
            }
            onClicked: {
                console.debug("Click: "+index)
                ListView.currentIndex=index
            }

            Text {
                id: c
                color: highlighted ? "red" : "#292929"
                padding: 8
                font.capitalization: Font.AllUppercase
                font.weight: Font.Bold
                text: topic;
                anchors.verticalCenter: parent.verticalCenter
                verticalAlignment: Text.AlignVCenter
                maximumLineCount: 1
                elide: Text.ElideRight
                font.pointSize: 18
                textFormat: Text.PlainText
                wrapMode: Text.NoWrap
                width: parent.width
            }
        }
    }

    SnowAnimation {
        id: particle
        running: showAnimation.checked
    }

}
