import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.15
import QtMultimedia 5.15
import QtQuick.XmlListModel 2.15

import ".."
import "../animations"
import "../delegates"
import "../models"
import "../components"

Window {
    id: outputWindow
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

    property int tickerItemsVisible: 4
    property bool tickerVisible: menuTickerVisible.checked;

    property alias newsTickerVisible: newsTicker.visible
    property alias lowerThirdsVisible: l3.visible
    property alias timersVisible: cl.visible

    property ListModel newsTickerModel: tickerModel

    property MediaPlayer mediaPlayer;

    property MaskWindow maskWindow;

    property bool useMask: false

    property bool useDropShadows: true

    Component.onCompleted: {
        startTime=new Date()
    }

    onFrameSwapped: {
        if (!maskWindow || !useMask)
            return;

        contentItem.grabToImage(function(result) {
            maskWindow.mask = String(result.url);
        });
    }

    onClosing: {
        close.accepted=false;
    }

    MessageListModel {
        id: msgModelLeft
    }
    MessageListModel {
        id: msgModelRight
    }

    ListModel {
        id: tickerModel
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

    MouseArea {
        anchors.fill: parent
        onDoubleClicked: {
            outputWindow.visibility=outputWindow.visibility==Window.FullScreen ? Window.Windowed : Window.FullScreen
        }
    }
    
    Image {
        id: img
        anchors.fill: parent
    }

    function setMediaPosition(x,y,w,h) {
        vo.x=x*vo.parent.width;
        vo.y=y*vo.parent.height;
        vo.width=w*vo.parent.width;
        vo.height=h*vo.parent.height;
    }

    VideoOutput {
        id: vo
        source: mediaPlayer
        x: 0
        y: 0
        width: parent.width
        height: parent.height
        autoOrientation: true;
    }

    VideoOutput {
        id: vovi
        source: videoInput
        x: 0
        y: 0
        width: parent.width
        height: parent.height
        autoOrientation: true
    }

    function startCamera() {
        videoInput.start();
    }

    function stopCamera() {
        videoInput.stop();
    }

    function setVideoOutputSource(src) {
        switch (src) {
        case 0:
            vo.source=mediaPlayer;
            break;
        case 1:
            vo.source=videoInput;
            break;
        }
    }

    Camera {
        id: videoInput
        deviceId: "/dev/video0"
        captureMode: Camera.CaptureViewfinder
        cameraState: Camera.LoadedState
        onErrorStringChanged: console.debug("CameraError: "+errorString)
        onCameraStateChanged: {
            console.debug("Camera State: "+cameraState)
            switch (cameraState) {
            case Camera.ActiveState:
                console.debug("DigitalZoom: "+maximumDigitalZoom)
                console.debug("OpticalZoom: "+maximumOpticalZoom)
                console.debug(imageCapture.resolution)
                break;
            }
        }
        onCameraStatusChanged: console.debug("CameraStatus: "+cameraStatus)

        onDigitalZoomChanged: console.debug(digitalZoom)

        focus {
            focusMode: Camera.FocusContinuous
            focusPointMode: Camera.FocusPointCenter
        }

        imageCapture {
            onImageCaptured: {
                console.debug("Image captured!")
                console.debug(camera.imageCapture.capturedImagePath)
                //                previewImage.source=preview;
            }
            onCaptureFailed: {
                console.debug("Capture failed")
            }
            onImageSaved: {
                console.debug("Image saved: "+path)
                //                cameraItem.imageCaptured(path)
            }
        }

        onError: {
            console.log("Camera reports error: "+errorString)
            console.log("Camera Error code: "+errorCode)
        }

        Component.onCompleted: {
            console.debug("Camera is: "+deviceId)
            console.debug("Camera orientation is: "+orientation)
            videoInput.exposure.exposureMode=Camera.ExposureAuto
        }
    }
    
    Grid {
        id: mainGrid
        anchors.fill: parent
        anchors.bottomMargin: bm(l3.visible, newsTicker.visible);
        columns: 3
        spacing: 16
        
        function bm(ltv, nt) {
            bm=0;
            if (ltv) bm+=l3.height+32
            if (nt) bm+=newsTicker.height+32
            return bm;
        }
        
        move: Transition {
            NumberAnimation {
                easing.type: Easing.InOutQuad
                properties: "x,y";
                duration: 750
            }
        }
        add: Transition {
            NumberAnimation {
                easing.type: Easing.InOutQuad
                properties: "x,y";
                duration: 750;
            }
        }
        Behavior on anchors.bottomMargin {
            NumberAnimation { duration: 500 }
        }
        
        Rectangle {
            id: leftSide
            color: "transparent"
            width: mainGrid.width/4
            height: parent.height
        }
        Rectangle {
            id: middleSide
            color: "transparent"
            width: mainGrid.width/2
            height: parent.height
        }
        Rectangle {
            id: rightSide
            color: "transparent"
            width: mainGrid.width/4
            height: parent.height
        }
    }

    DropShadow {
        visible: useMask && useDropShadows
        anchors.fill: mainGrid
        horizontalOffset: 4
        verticalOffset: 4
        radius: 8.0
        samples: 17
        color: "#80000000"
        source: mainGrid
    }

    MessageListView {
        parent: leftSide
        id: msgLeftBottom
        anchors.fill: parent
        anchors.leftMargin: 32
        model: msgModelLeft
        delegate: msgDelegate
        visible: switchMessageListLeft.checked
    }

    MessageListView {
        id: msgRightBottom
        parent: rightSide
        anchors.fill: parent
        anchors.rightMargin: 32
        model: msgModelRight
        delegate: msgDelegate
        xpos: x+width+32
        visible: switchMessageListRight.checked
    }

    LowerThirdBase {
        id: l3
        mainTitle: main.primary
        secondaryTitle: main.secondary
        displayTime: delayTime.value*1000
    }
    
    Column {
        id: cl
        parent: middleSide
        anchors.centerIn: parent
        anchors.leftMargin: 32
        anchors.rightMargin: 32
        anchors.topMargin: 32
        anchors.bottomMargin: 32
        spacing: 16
        height: Math.min(childrenRect.height, parent.height)
        width: parent.width

        property real fontSizeRatioTime: 5

        move: Transition {
            NumberAnimation {
                easing.type: Easing.InOutQuad
                properties: "x,y";
                duration: 750
            }
        }
        add: Transition {
            NumberAnimation {
                easing.type: Easing.InOutQuad
                properties: "x,y";
                duration: 750;
            }
        }

        TimeText {
            id: msgText
            minimumPixelSize: 42
            font.pixelSize: 82
            visible: text!=""
            wrapMode: Text.Wrap
            maximumLineCount: 4
            horizontalAlignment: lineCount<2 ? Text.AlignHCenter : Text.AlignLeft
            height: cl.parent.height/4
        }
        TimeText {
            id: timeCurrent
            visible: showTime.checked
        }
        TimeText {
            id: timeCount
            visible: showCounter.checked
            text: formatSeconds(tickerUp.seconds)
        }
        TimeText {
            id: timeCountdown
            text: formatSeconds(ticker.countdown)
            visible: showCountdown.checked
        }
    }

    ColumnLayout {
        id: newsTicker
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 32
        spacing: 0
        visible: tickerModel.count>0 && tickerVisible && !l3.visible

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
            highlightMoveDuration: 500
            snapMode: ListView.SnapToItem
            highlightRangeMode: ListView.StrictlyEnforceRange
            onCurrentIndexChanged: {
                console.debug("Tick: "+currentIndex)
                tickerMsg.text=tickerModel.get(currentIndex).msg
                tickerMsg.opacity=1
                tickerMsgContainer.opacity=1
            }
        }

        Rectangle {
            id: tickerDelayBar
            height: 12
            color: "#00855f"
            width: (parent.width/100)*tickerTimer.ct
            opacity: tickerMsg.opacity
            Behavior on width { NumberAnimation { } }
            Behavior on opacity { NumberAnimation { } }
        }

        Rectangle {
            id: tickerMsgContainer
            height: tickerMsg.height+16
            Layout.fillWidth: true
            color: "#ffffff"
            Behavior on opacity { NumberAnimation { duration: 500 } }
            Text {
                id: tickerMsg
                color: "#0062ae"
                padding: 8
                maximumLineCount: 2 // XXX Make adjustable
                width: parent.width
                height: outputWindow.height>720 ? 96 : 64
                elide: Text.ElideRight
                font.pixelSize: outputWindow.height>720 ? 28 : 24
                textFormat: Text.PlainText
                wrapMode: Text.Wrap
                text: ""
                Behavior on opacity { NumberAnimation { duration: 250 } }
            }
        }
    }

    DropShadow {
        visible: useMask && newsTicker.visible && useDropShadows
        anchors.fill: newsTicker
        horizontalOffset: 4
        verticalOffset: 4
        radius: 8.0
        samples: 17
        color: "#80000000"
        source: newsTicker
    }

    Component {
        id: tickerHighlight
        Rectangle {
            color: "#009bd8"
            Behavior on x {
                NumberAnimation { }
            }
        }
    }

    Component {
        id: tickerDelegate
        ItemDelegate {
            width: tickerList.width/tickerItemsVisible
            highlighted: ListView.isCurrentItem
            height: c.height+c.padding
            background: Rectangle {
                color: highlighted ? "#ffffff" : "#b0b0b0"
                radius: 0
            }
            onClicked: {
                console.debug("Click: "+index)
                ListView.currentIndex=index
            }

            Text {
                id: c
                color: highlighted ? "#0062ae" : "#0062ae"
                padding: 8
                font.capitalization: Font.AllUppercase
                font.weight: Font.Bold
                text: topic;
                anchors.verticalCenter: parent.verticalCenter
                verticalAlignment: Text.AlignVCenter
                maximumLineCount: 1
                elide: Text.ElideRight
                font.pixelSize: 32 // XXX
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
