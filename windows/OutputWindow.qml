import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.12
import QtMultimedia

import Qt5Compat.GraphicalEffects

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
    x: screen.virtualX
    y: screen.virtualY
    modality: Qt.NonModal
    transientParent: null
    color: "black"

    property var startTime;

    property bool spanWindow: false;

    property alias lowerThirdsFullWidth: l3l.fullWidth
    property alias lowerThirdsMargin: l3l.margin

    property alias messageVisible: msgText.visible
    property alias messageText: msgText.text

    property alias tickerItemsVisible: newsTicker.itemsVisible
    property alias tickerVisible: newsTicker.tickerVisible    

    property alias newsTickerVisible: newsTicker.visible
    property alias newsTickerShow: newsTicker.showItem

    property alias newsPanelVisible: newsPanel.visible
    property alias newsPanelShow: newsPanel.tickerVisible

    property bool lowerThirdsVisible: l3l.visible || l3r.visible

    property LowerThirdBase lthirdLeft: l3l
    property LowerThirdBase lthirdRight: l3r

    property ListModel newsTickerModel: tickerModel
    property ListModel newsPanelModel: panelModel

    property QrCode qrCode: qrcode

    property MediaPlayer mediaPlayer;

    property MaskWindow maskWindow;

    property bool useMask: false

    property bool useDropShadows: true

    property bool hasVideoInput: mediaDevices.videoInputCount>0
    property bool videoInputActive: videoInput.active && hasVideoInput

    readonly property CustomVideoOutput mediaPlayerOutput: vo
    readonly property CustomVideoOutput videoInputOutput: vovi
    
    property Image outputImage;
    property bool outputPreview: false

    readonly property Clapper clapper: clapper
    property alias clapperVisible: clapper.visible
    
    property alias txtTime: timeCurrent
    property alias txtCountdown: timeCountdown
    property alias txtUp: timeCount
    property alias txtMessage: msgText

    Component.onCompleted: {
        startTime=new Date()
    }

    onScreenChanged: {
        console.debug("OutputWindowScreen is now: "+screen.name)
        settings.setSettingsStr("windows/mainwindow", screen.name)
    }

    onFrameSwapped: {
        if (!maskWindow && !useMask && !outputPreview)
            return;
        
        contentItem.grabToImage(function(result) {
            if (maskWindow && useMask)
                maskWindow.mask = String(result.url);
            if (outputImage && outputPreview)
                outputImage.source = String(result.url);
        });
    }

    onClosing: (close) => {        
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

    ListModel {
        id: panelModel
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

    function setBackground(bg, src='') {
        switch (bg) {
        case 'black':
        case 'green':
        case 'blue':
            color=bg
            img.source='';
            break;
        case 'image':
            color='black'
            img.source=src;
            break;
        case 'custom':
            color=src
            img.source='';
            break;
        default:
            color='black'
        }
    }

    function setTickerPosition(align) {
        newsTicker.position.setPosition(Qt.AlignLeft, align)
    }

    function setMessage(msg) {
        msgText.text=msg;
    }

    function setSubtitle(msg) {
        subTitle.text=msg;
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
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        anchors.fill: parent
        visible: source!==''
    }

    CustomVideoOutput {
        id: vo        
    }

    CustomVideoOutput {
        id: vovi        
    }

    function startCamera() {
        videoInput.start();
    }

    function stopCamera() {
        videoInput.stop();
    }

    function videoOutputVisible(v) {
        vovi.visible=v;
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
    
    Grid {
        id: mainGrid
        anchors.fill: parent
        anchors.bottomMargin: bm(l3l.visible || l3r.visible, newsTicker.visible);
        columns: 3
        spacing: 16
        
        function bm(ltv, nt) {
            let tbm=16;
            if (ltv) tbm+=l3l.height+32
            if (nt) tbm+=newsTicker.height+32
            return tbm;
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
            width: mainGrid.width/3
            height: parent.height
        }
        Rectangle {
            id: middleSide
            color: "transparent"
            width: mainGrid.width/3
            height: parent.height
        }
        Rectangle {
            id: rightSide
            color: "transparent"
            width: mainGrid.width/3
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

    /* Left side */
    LowerThirdBase {
        id: l3l
        displayTime: delayTime.value*1000
        fullWidth: menuThirdsFullWidth.checked
    }
    
    /* Right side */
    LowerThirdBase {
        id: l3r
        margin: l3l.margin
        displayTime: delayTime.value*1000
        fullWidth: menuThirdsFullWidth.checked
        alignHorizontal: Qt.AlignRight
    }
    
    function setPosition(item, ax, ay) {
        item.position.setPosition(ax, ay);
    }
    
    TimeText {
        id: timeCurrent
        visible: showTime.checked
        text: Qt.formatTime(main.date, "hh:mm:ss");
        Component.onCompleted: {
            position.setPosition(Qt.AlignCenter, Qt.AlignCenter)
        }
    }
    TimeText {
        id: timeCount
        visible: showCounter.checked
        text: formatSeconds(tickerUp.seconds)
        Component.onCompleted: {
            position.setPosition(Qt.AlignLeft, Qt.AlignBottom)
        }
    }
    TimeText {
        id: timeCountdown
        text: formatSeconds(ticker.countdown)
        visible: showCountdown.checked
        Component.onCompleted: {
            position.setPosition(Qt.AlignRight, Qt.AlignBottom)
        }
    }

    MessageText {
        id: msgText
        visible: false
        Component.onCompleted: {
            position.setPosition(Qt.AlignCenter, Qt.AlignTop)
        }
    }

    SubTitle {
        id: subTitle
        text: ""
        Component.onCompleted: {
            position.setPosition(Qt.AlignCenter, Qt.AlignBottom)
        }
    }

    NewsPanel {
        id: newsPanel
        model: panelModel
        Component.onCompleted: {
            position.setPosition(Qt.AlignCenter, Qt.AlignTop)
        }
    }

    NewsTicker {
        id: newsTicker
        model: tickerModel
        needToHide: lowerThirdsVisible
    }

    QrCode {
        id: qrcode
        Component.onCompleted: {
            position.setPosition(Qt.AlignRight, Qt.AlignTop)
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

    SnowAnimation {
        id: particle
        visible: showAnimation.checked
        emitting: activeAnimation.checked
    }

    Clapper {
        id: clapper
        visible: false
        anchors.fill: parent
    }

}
