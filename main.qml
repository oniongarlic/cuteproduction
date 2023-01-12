import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.15
import QtMultimedia 5.15
import QtQuick.XmlListModel 2.15
import QtQuick.Dialogs 1.3

import org.tal 1.0
import org.tal.cutehyper 1.0
import org.tal.mqtt 1.0

import "windows"
import "selectors"
import "messaging"
import "components"
import "models"

ApplicationWindow {
    id: main
    width: 1024
    height: 768
    minimumHeight: 600
    minimumWidth: 800
    visible: true
    title: qsTr("CuteProduction")
    //visibility: Window.FullScreen
    //flags: Qt.WA_TranslucentBackground
    property int oflags;
    //color: "#00000040"
    color: "#F0F0F0"
    
    property OutputWindow l3window;
    property MaskWindow maskwindow;
    property TelepromptWindow tpwindow;

    FontLoader {
        id: staticFontOxygenMono
        source: "qrc:/data/fonts/OxygenMono-Regular.ttf"
        onNameChanged: console.debug("FontName: "+name)
        onStatusChanged: console.debug("FontStatus: "+status)
    }

    Component.onCompleted: {
        oflags=flags;
        
        console.debug("Loading settings...")
        loadSettings()
        console.debug("...done")
        
        console.debug("Screens: " + Qt.application.screens.length)
        let l3s=0;
        let tps=0;
        let mps=0;
        
        for(var i = 0;i < Qt.application.screens.length;i ++) {
            console.debug(i)
            console.debug(Qt.application.screens[i])
        }
        
        if (Qt.application.screens.length>1) {
            l3s=1;
            tps=1;
        }
        if (Qt.application.screens.length>2) {
            tps=2;
        }
        if (Qt.application.screens.length>3) {
            mps=3;
        }
        
        l3window=aws.createObject(null, { screen: Qt.application.screens[l3s], visible: true });
        tpwindow=tpw.createObject(null, { screen: Qt.application.screens[tps], visible: false });
        maskwindow=maskw.createObject(null, { screen: Qt.application.screens[mps], visible: false });
        
        l3window.maskWindow=maskwindow;

        mqttClient.connectToHost();
    }
    
    onClosing: {
        Qt.quit();
    }
    
    function formatSeconds(s) {
        var h = Math.floor(s / 3600);
        s %= 3600;
        var m = Math.floor(s / 60);
        var ss = s % 60;
        return [h,m,ss].map(v => v < 10 ? "0" + v : v).join(":")
    }
    
    FileReader {
        id: fr
    }
    
    Component {
        id: tpw
        TelepromptWindow {
            id: teleWindow
            mirror: telepromptMirror.checked
            flip: telepromptFlip.checked
            onFlipChanged: settings.setSettings("teleprompt/flip", flip)
            onMirrorChanged: settings.setSettings("teleprompt/mirror", mirror)
            onVisibleChanged: settings.setSettings("telepromt/visible", visible)
        }
    }
    
    Component {
        id: maskw
        MaskWindow {
            id: maskWindow
            onVisibleChanged: settings.setSettings("mask/visible", visible)
        }
    }
    
    Component {
        id: aws
        OutputWindow {
            tickerItemsVisible: menuTickerFullWidth.checked ? 1 : 4
            tickerVisible: menuTickerVisible.checked
            mediaPlayer: mp

            onTickerItemsVisibleChanged: settings.setSettings("ticker/items", tickerItemsVisible)
            onTickerVisibleChanged: settings.setSettings("ticker/visible", tickerVisible)
        }
    }

    function loadSettings() {
        menuTickerVisible.checked=settings.getSettingsBool("ticker/visible", false);
        menuTickerFullWidth.checked=settings.getSettingsInt("ticker/items", 1, 1, 4)===1 ? true : false;
    }
    
    menuBar: MenuBar {
        Menu {
            title: "File"
            MenuItem {
                text: "Quit"
                onClicked: Qt.quit()
            }
        }
        Menu {
            title: "View"
            MenuItem {
                text: "Full screen (Operation)"
                checkable: true
                checked: visibility==Window.FullScreen ? true : false
                onCheckedChanged: visibility=!checked ? Window.Windowed : Window.FullScreen
            }
            MenuItem {
                text: "Full screen (View)"
                checkable: true
                checked: l3window.visibility==Window.FullScreen ? true : false
                onCheckedChanged: l3window.visibility=!checked ? Window.Windowed : Window.FullScreen
            }
            MenuItem {
                text: "Use mask"
                checkable: true
                checked: false
                onCheckedChanged: {
                    l3window.useMask=checked;
                    if (checked && !maskwindow.visible) {
                        maskwindow.visible=true;
                    } else {
                        maskwindow.visible=false;
                    }
                }
            }
            MenuItem {
                text: "Full screen (Mask)"
                checkable: true
                checked: maskwindow.visibility==Window.FullScreen ? true : false
                onCheckedChanged: maskwindow.visibility=!checked ? Window.Windowed : Window.FullScreen
            }            
        }
        
        Menu {
            title: "Message"
            MenuItem {
                text: "Copy"
                enabled: textMsg.selectionEnd!=textMsg.selectionStart
                onClicked: textMsg.copy()
            }
            MenuItem {
                text: "Paste"
                enabled: textMsg.canPaste
                onClicked: textMsg.paste()
            }
            MenuItem {
                text: "Undo"
                enabled: textMsg.canUndo
                onClicked: textMsg.undo()
            }
            MenuItem {
                text: "Select all"
                onClicked: textMsg.selectAll()
            }
            MenuSeparator {
                
            }
            MenuItem {
                text: "Clear all"
                onClicked: textMsg.clear()
            }
        }
        Menu {
            title: "Chat"
            MenuItem {
                text: "Manage..."
                onClicked: {
                    chatDrawer.open()
                }
            }
            MenuSeparator {
                
            }
            MenuItem {
                text: "IRC Source"
                onClicked: {
                    ircDrawer.open();
                }
            }
            MenuItem {
                text: "Route message"
                checkable: true
                onCheckedChanged: {
                    
                }
            }
        }
        
        Menu {
            title: "Thirds"
            MenuItem {
                text: "Open..."
                onClicked: tsf.startSelector();
            }
            MenuItem {
                text: "Manage.."
                onClicked: {
                    thirdsDrawer.open()
                }
            }
            MenuItem {
                id: menuThirdsFullWidth
                text: "Full width"
                checkable: true
                checked: false
            }
            MenuSeparator {
                
            }
            MenuItem {
                text: "Clear"
                onClicked: {
                    l3ModelFinal.clear()
                }
            }
        }
        Menu {
            title: "Prompt"
            MenuItem {
                text: "Manage..."
                enabled: true
                onClicked: telepromptDrawer.open()
            }
            MenuItem {
                text: "Load text..."
                enabled: true
                onClicked: tsftp.startSelector();
            }
            MenuItem {
                text: "Paste text"
                enabled: textPrompter.canPaste
                onClicked: {
                    textPrompter.paste()
                    tpwindow.telepromptSetText(textPrompter.text)
                }
            }
            MenuSeparator {
                
            }
            MenuItem {
                text: "Clear text"
                onClicked: {
                    tpwindow.telepromptSetText("")
                }
            }
            MenuSeparator {
                
            }
            MenuItem {
                text: "Show window"
                checkable: true
                onCheckedChanged: {
                    tpwindow.visible=checked
                }
            }
            MenuItem {
                text: "Full screen"
                checkable: true
                enabled: tpwindow.visible
                checked: tpwindow.visibility==Window.FullScreen ? true : false
                onCheckedChanged: tpwindow.visibility=!checked ? Window.Windowed : Window.FullScreen
            }
        }
        
        Menu {
            title: "News"
            MenuItem {
                text: "Manage.."
                onClicked: {
                    newsDrawer.open()
                }
            }
            MenuItem {
                id: menuTickerVisible
                text: "Ticker visible"
                checkable: true
                checked: false
            }
            MenuItem {
                id: menuTickerFullWidth
                text: "Full width title"
                checkable: true
                checked: false
            }
            MenuItem {
                text: "Align Top"
                onClicked: l3window.setTickerPosition(Qt.AlignTop)
            }
            MenuItem {
                text: "Align Bottom"
                onClicked: l3window.setTickerPosition(Qt.AlignBottom)
            }
            MenuSeparator {
                
            }
            MenuItem {
                text: "Clear"
                onClicked: {
                    l3window.clearNews()
                }
            }
        }
        
        Menu {
            title: "Media"
            MenuItem {
                text: "Manage..."
                onClicked: {
                    mediaDrawer.open()
                }
            }
            MenuItem {
                text: "Add file..."
                onClicked: {
                    ms.startSelector()
                }
            }
            MenuItem {
                text: "Add URL..."
                onClicked: {
                    usd.open()
                }
            }
            MenuItem {
                text: "Open playlist..."
                onClicked: {
                    playListSelector.startSelector();                    
                }
            }
            MenuItem {
                text: "Save playlist as..."
                onClicked: {
                    playListSaveSelector.startSelector();
                }
            }
            MenuItem {
                text: "Clear"
                onClicked: {
                    plist.clear()
                }
            }
            Menu {                
                title: "Video input"
                enabled: l3window.hasVideoInput
                MenuItem {
                    text: "Start"                    
                    onClicked: {
                        l3window.startCamera();
                    }
                }
                MenuItem {
                    text: "Stop"
                    enabled: l3window.videoInputActive
                    onClicked: {
                        l3window.stopCamera();
                    }
                }
                MenuItem {
                    text: "Select"
                    enabled: !l3window.videoInputActive
                    onClicked: {
                        cameraSelector.open()
                    }
                }
                MenuItem {
                    text: "Show"
                    checkable: true
                    checked: true
                    onClicked: {
                        l3window.videoOutputVisible(checked)
                    }
                }
            }
        }
        
        Menu {
            title: "Background"                       
            
            ColorMenuItem {
                id: bgBlack
                text: "Black"
                value: "black"
                checkable: true
                checked: true
                ButtonGroup.group: backgroundGroup
            }
            ColorMenuItem {
                id: bgGreen
                text: "Green"
                value: "green"
                checkable: true
                ButtonGroup.group: backgroundGroup
            }
            ColorMenuItem {
                id: bgBlue
                text: "Blue"
                value: "blue"
                checkable: true
                ButtonGroup.group: backgroundGroup
            }
            ColorMenuItem {
                id: bgCustom
                text: "Custom"
                checkable: true
                value: dialogColor.color
                ButtonGroup.group: backgroundGroup
                onClicked: {
                    dialogColor.open()
                }
            }
            MenuSeparator {
                
            }
            MenuItem {
                id: bgImage
                text: "Image..."
                onClicked: {
                    tsimg.startSelector()
                }
            }
            MenuItem {
                id: bgImageClear
                text: "Clear"
                onClicked: {
                    l3window.setBackground('image', '');
                    l3window.setBackground(backgroundGroup.currentValue);                    
                }
            }
        }
    }

    CameraSelectorPopup {
        id: cameraSelector
        onCameraSelected: {
            l3window.setCameraDevice(id)
        }
    }

    CameraResolutionPopup {
        id: cameraResolutionSelector
        onCameraResolutionSelected: {

        }
    }
    
    ButtonGroup {
        id: backgroundGroup
        property string currentValue: 'black';
        onClicked: {
            l3window.setBackground(button.value)
            currentValue=button.value
        }
        onCurrentValueChanged: {
            settings.setSettingsStr("background/color", currentValue)
        }
    }
    
    ColorDialog {
        id: dialogColor
        onAccepted: {
            l3window.setBackground('custom', color);
            backgroundGroup.currentValue=color;
        }
        onRejected: {
            
        }
        Component.onCompleted: {
            color=settings.getSettingsStr("background/customColor", "yellow")
        }
        onColorChanged: {
            settings.setSettingsStr("background/customColor", color)
        }
    }
    
    TextSelector {
        id: tsimg
        filter: [ "*.jpg" ]
        onFileSelected: {
            l3window.setBackground('image', src)
            settings.setSettingsStr("background/image", src)
        }
    }
    
    TextSelector {
        id: tsftp
        filter: [ "*.txt" ]
        onFileSelected: {
            fr.read(src)
            textPrompter.text=fr.data();
        }
    }
    
    TextSelector {
        id: tsf
        filter: [ "*.xml" ]
        onFileSelected: {
            l3Model.source=src
        }
    }
    
    TextSelector {
        id: playListSelector
        filter: [ "*.m3u8" ]
        onFileSelected: {
            plist.load(src, "m3u8")
        }
    }
    
    TextSelector {
        id: playListSaveSelector
        filter: [ "*.m3u8" ]
        selectExisting: false
        onFileSelected: {
            plist.save(src, "m3u8");
        }
    }
    
    URLSelector {
        id: usd
        onAccepted: {
            plist.addItem(url)
        }
    }
    
    function selectMediaFile() {
        ms.startSelector()
    }
    
    function nextMediaFile() {
        plist.playbackMode=Playlist.Sequential
        plist.next();
        mp.pause();
        plist.playbackMode=Playlist.CurrentItemOnce
    }
    
    function previousMediaFile() {
        plist.playbackMode=Playlist.Sequential
        plist.previous();
        mp.pause();
        plist.playbackMode=Playlist.CurrentItemOnce
    }
    
    function setMediaFile(i) {
        plist.currentIndex=i;
        mp.pause();
        plist.playbackMode=Playlist.CurrentItemOnce
    }
    
    MediaSelector {
        id: ms
        
        onFileSelected: {
            plist.addItem(src)
            mp.pause();
            //hs.setClips(plist.itemCount)
        }
        
        onFilesSelected: {
            plist.addItems(src)
            //hs.setClips(plist.itemCount)
        }
    }
    
    MediaPlayer {
        id: mp
        playlist: plist
        autoLoad: true
        loops: checkLoop.checked ? MediaPlayer.Infinite : 1
        muted: checkMuted.checked
        volume: volumeDial.value/100
        audioRole: MediaPlayer.VideoRole
        onPlaying: {
            //hs.setStatus("playing")
        }
        onStopped: {
            //hs.setStatus("stopped")
        }
        onPaused: {
            //hs.setStatus("stopped")
        }
        onPositionChanged: {
            //hs.setTimecode(position);
        }
        onDurationChanged: {
            //hs.setDuration(duration)
        }
        
        onStatusChanged: console.debug(status)
    }
    
    Playlist {
        id: plist
        playbackMode: Playlist.CurrentItemOnce
        onLoaded: {
            console.debug("Playlist loaded: "+itemCount)
        }
        onLoadFailed: {
            console.debug(errorString)
        }
    }
    
    HyperServer {
        id: hs
        onPlay: {
            console.debug("HyperPLAY")
            mp.play();
        }
        onRecord: {
            console.debug("HyperRECORD")
            hs.setStatus("stopped")
        }
        onStop: {
            console.debug("HyperSTOP")
            mp.stop();
        }
        onLoopChanged: {
            if (loop>1) {
                plist.playbackMode=Playlist.CurrentItemInLoop
            } else {
                plist.playbackMode=Playlist.CurrentItemOnce
            }
        }
    }
    
    Drawer {
        id: mediaDrawer
        dragMargin: 0
        width: parent.width/1.5
        height: parent.height
        DropArea {
            id: mediaDropArea
            anchors.fill: parent
            // XXX: huh?
            //keys: ["video/quicktime", "video/mp4", "audio/mpeg", "audio/mp3", "audio/flac", "application/ogg"]
            onDropped: {
                if (drop.hasUrls) {
                    console.debug(drop.urls[0])
                    mediaListView.model.addItems(drop.urls);
                    drop.acceptProposedAction()
                }
            }
        }
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 8
            ListView {
                id: mediaListView
                Layout.fillHeight: true
                Layout.fillWidth: true
                model: plist
                clip: true
                delegate: playlistDelegate
                highlight: Rectangle { color: "#f0f0f0"; }
                ScrollIndicator.vertical: ScrollIndicator { }
            }
            
            RowLayout {
                spacing: 8
                Button {
                    text: "Add"
                    onClicked: {
                        ms.startSelector();
                    }
                }
                Button {
                    text: "Add URL"
                    onClicked: {
                        usd.open()
                    }
                }
                Button {
                    text: "Remove"
                    enabled: mediaListView.currentIndex>-1
                    onClicked: {
                        mediaListView.model.remove(mediaListView.currentIndex)
                    }
                }
                Button {
                    text: "Clear"
                    onClicked: {
                        plist.clear()
                    }
                }
                Button {
                    text: "Close"
                    onClicked: {
                        mediaDrawer.close()
                    }
                }
            }
            
            RowLayout {
                spacing: 8
                Label {
                    id: conMsg
                    text: mp.errorString
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignLeft
                }
                Label {
                    id: bufMsg
                    text: mp.bufferProgress
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignLeft
                }
                Label {
                    id: itemsMsg
                    text: 1+plist.currentIndex+" / "+plist.itemCount
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignLeft
                }
                Label {
                    id: itemTime
                    text: formatSeconds(mp.position/1000)+" / "+formatSeconds(mp.duration/1000)
                }
            }
            
            RowLayout {
                spacing: 8
                Slider {
                    id: volumeDial
                    from: 0
                    to: 100
                    value: 100
                    stepSize: 1
                    wheelEnabled: true
                    
                    NumberAnimation {
                        id: volumeFadeIn
                        //from: 0
                        to: 100
                        target: volumeDial
                        property: "value"
                        duration: 500
                        easing.type: Easing.InOutQuad
                    }
                    NumberAnimation {
                        id: volumeFadeOut
                        //from: 100
                        to: 0
                        target: volumeDial
                        property: "value"
                        duration: 500
                        easing.type: Easing.InOutQuad
                    }
                }
                
                CheckBox {
                    id: checkMuted
                    text: "Mute"
                    checked: mp.muted
                }
                
                Button {
                    text: "Fade In"
                    enabled: !volumeFadeIn.running
                    onClicked: volumeFadeIn.start()
                }
                Button {
                    text: "Fade Out"
                    enabled: !volumeFadeOut.running
                    onClicked: volumeFadeOut.start()
                }
                CheckBox {
                    id: checkLoop
                    text: "Loop"
                    checked: mp.loops!=1
                }
            }
            
            RowLayout {
                spacing: 8
                Button {
                    text: "Play"
                    enabled: mp.playbackState!=MediaPlayer.PlayingState && mp.status!=MediaPlayer.NoMedia
                    onClicked: {
                        mp.play();
                    }
                }
                Button {
                    text: "Pause"
                    enabled: mp.playbackState==MediaPlayer.PlayingState
                    onClicked: {
                        mp.pause()
                    }
                }
                Button {
                    text: "Stop"
                    enabled: mp.playbackState==MediaPlayer.PlayingState
                    onClicked: {
                        mp.stop();
                    }
                }
                Button {
                    text: "Previous"
                    onClicked: {
                        previousMediaFile();
                    }
                }
                Button {
                    text: "Next"
                    onClicked: {
                        nextMediaFile();
                    }
                }
            }
        }
    }
    
    Component {
        id: playlistDelegate
        ItemDelegate {
            width: ListView.view.width
            height: c.height
            highlighted: ListView.isCurrentItem
            RowLayout {
                id: c
                spacing: 4
                width: parent.width
                Text {
                    Layout.fillWidth: true
                    text: source
                    font.pointSize: 14
                }
            }
            onClicked: {
                ListView.currentIndex=index;
            }
            onDoubleClicked: {
                setMediaFile(index)
            }
        }
    }
    
    Drawer {
        id: chatDrawer
        dragMargin: 0
        width: parent.width/1.5
        height: parent.height
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 8
            Frame {
                Layout.fillWidth: true
                Layout.fillHeight: true
                ColumnLayout {
                    anchors.fill: parent
                    TextField {
                        id: bP
                        Layout.fillWidth: true
                        selectByMouse: true
                        placeholderText: "Topic/Name/Keyword"
                    }
                    TextArea {
                        id: bS
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        selectByKeyboard: true
                        selectByMouse: true
                        placeholderText: "Message"
                        textFormat: TextEdit.PlainText
                        wrapMode: TextEdit.Wrap
                    }
                    RowLayout {
                        Switch {
                            id: switchMessageListLeft
                            Layout.alignment: Qt.AlignLeft
                            text: "Left"
                            onCheckedChanged: {
                            }
                        }
                        Button {
                            text: "Send"
                            enabled: bS.length>0
                            onClicked: {
                                l3window.addMessageLeft(bP.text, bS.text);
                                bP.text=''
                                bS.text=''
                            }
                        }
                        Button {
                            text: "Remove"
                            onClicked: {
                                l3window.removeMessageLeft();
                            }
                        }
                        Button {
                            text: "Clear"
                            onClicked: {
                                l3window.clearMessagesLeft();
                            }
                        }
                    }
                    RowLayout {
                        Switch {
                            id: switchMessageListRight
                            Layout.alignment: Qt.AlignLeft
                            text: "Right"
                            onCheckedChanged: {
                            }
                        }
                        Button {
                            text: "Send"
                            enabled: bP.length>0
                            onClicked: {
                                l3window.addMessageRight(bP.text, bS.text);
                                bP.text=''
                                bS.text=''
                            }
                        }
                        Button {
                            text: "Remove"
                            onClicked: {
                                l3window.removeMessageRight();
                            }
                        }
                        Button {
                            text: "Clear"
                            onClicked: {
                                l3window.clearMessagesRight();
                            }
                        }
                    }
                }
            }
        }
    }
    
    Drawer {
        id: ircDrawer
        dragMargin: 0
        width: parent.width/1.5
        height: parent.height
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 8
            TextField {
                id: ircHostname
                Layout.fillWidth: true
                placeholderText: "Hostname"
                selectByMouse: true
            }
            TextField {
                id: ircPassword
                Layout.fillWidth: true
                placeholderText: "Password"
                selectByMouse: true
            }
            Switch {
                id: ircSecure
                text: "Secure connection"
                checked: false
            }
            TextField {
                id: ircNick
                Layout.fillWidth: true
                placeholderText: "Nick"
                selectByMouse: true
            }
            TextField {
                id: ircRealname
                Layout.fillWidth: true
                placeholderText: "Real name"
                selectByMouse: true
            }
            TextField {
                id: ircChannel
                Layout.fillWidth: true
                placeholderText: "Channel"
                selectByMouse: true
            }
            TextField {
                id: ircChannelKey
                Layout.fillWidth: true
                placeholderText: "Channel key"
                selectByMouse: true
            }
            RowLayout {
                Button {
                    text: "Connect"
                    enabled: !irc.connected && ircHostname.length>1
                    onClicked: {
                        irc.connect();
                    }
                }
                Button {
                    text: "Disconnect"
                    enabled: irc.connected
                    onClicked: {
                        irc.disconnect();
                    }
                }
            }
            Frame {
                visible: true
                Layout.fillHeight: true
                Layout.fillWidth: true
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 4
                    Label {
                        text: "Topic"
                    }
                    SplitView {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        ListView {
                            id: channel
                            SplitView.fillWidth: true
                            model: irc.channelModel
                            delegate: Label {
                                text: model.title
                            }
                        }
                        ListView {
                            id: users
                            SplitView.fillWidth: true
                            model: irc.userModel
                            delegate: Label {
                                text: model.title
                            }
                        }
                    }
                }
            }
        }
    }
    
    Drawer {
        id: thirdsDrawer
        dragMargin: 0
        width: parent.width/1.5
        height: parent.height
        
        function clearL3Input() {
            textl3Primary.clear()
            textl3Secondary.clear()
        }
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 8
            TextField {
                id: textl3Primary
                Layout.fillWidth: true
                placeholderText: "Primary (name, etc)"
                selectByMouse: true
            }
            TextField {
                id: textl3Secondary
                Layout.fillWidth: true
                placeholderText: "Secondary (title, e-mail, etc)"
                selectByMouse: true
            }
            TextField {
                id: textl3Topic
                Layout.fillWidth: true
                placeholderText: "Topic/Keyword"
                selectByMouse: true
            }
            RowLayout {
                spacing: 8
                Button {
                    text: "Add"
                    onClicked: {
                        const item={
                            "primary": textl3Primary.text,
                            "secondary": textl3Secondary.text,
                            "topic": textl3Topic.text,
                            "image": ""}
                        l3ModelFinal.append(item)
                    }
                }
                Button {
                    text: "Clear"
                    onClicked: {
                        thirdsDrawer.clearL3Input();
                    }
                }
                Button {
                    text: "Close"
                    onClicked: {
                        thirdsDrawer.close()
                    }
                }
            }
        }
    }
    
    Drawer {
        id: newsDrawer
        dragMargin: 0
        width: parent.width/1.5
        height: parent.height
        DropArea {
            id: newsDropArea
            anchors.fill: parent
            keys: ["text/plain"]
            onDropped: {
                console.debug(drop.hasText)
                console.debug(drop.hasHtml)
                console.debug(drop.hasUrls)
                console.debug(drop.hasColor)
                
                if (drop.hasUrls) {
                    console.debug(drop.urls[0])
                    rssModel.source=drop.urls[0]
                    drop.acceptProposedAction()
                } else if (drop.hasText) {
                    console.debug(drop.text)
                    drop.acceptProposedAction()
                }
            }
        }
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 8
            TextField {
                id: newsKeyword
                Layout.fillWidth: true
                placeholderText: "Keyword"
                selectByMouse: true
            }
            ScrollView {
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.minimumHeight: newsDrawer.height/7
                Layout.maximumHeight: newsDrawer.height/6
                ScrollBar.vertical.policy: ScrollBar.AlwaysOn
                background: Rectangle {
                    border.color: "black"
                    border.width: 1
                }
                TextArea {
                    id: newsBody
                    Layout.maximumHeight: newsKeyword.height*4
                    placeholderText: "Body"
                    selectByKeyboard: true
                    selectByMouse: true
                    wrapMode: TextEdit.WordWrap
                }
            }
            RowLayout {
                spacing: 8
                Button {
                    text: "Add"
                    enabled: newsKeyword.length>0 && newsBody.length>0
                    onClicked: {
                        const item={ "topic": newsKeyword.text, "msg": newsBody.text }
                        l3window.addNewsItem(item)
                        newsKeyword.clear()
                        newsBody.clear()
                    }
                }
                Button {
                    text: "Update"
                    enabled: newsKeyword.length>0 && newsBody.length>0 && newsEditorList.currentIndex>-1
                    onClicked: {
                        const item={ "topic": newsKeyword.text, "msg": newsBody.text }
                        newsEditorList.model.set(newsEditorList.currentIndex, item)
                        newsKeyword.clear()
                        newsBody.clear()
                    }
                }
                Button {
                    text: "Remove"
                    enabled: newsEditorList.currentIndex>-1
                    onClicked: {
                        newsEditorList.model.remove(newsEditorList.currentIndex)
                    }
                }
                Button {
                    text: "Remove all"
                    onClicked: {
                        newsEditorList.model.clear();
                    }
                }
                Button {
                    text: "Clear"
                    onClicked: {
                        newsKeyword.clear()
                        newsBody.clear()
                    }
                }
                Button {
                    text: "Close"
                    onClicked: {
                        newsDrawer.close()
                    }
                }
            }
            ListView {
                id: newsEditorList
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: l3window.newsTickerModel
                delegate: newsEditorDelegate
                clip: true
            }
            Label {
                text: "Items: "+newsEditorList.count
            }
            ListView {
                id: newsFeedList
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: rssModel
                delegate: rssItemModel
                clip: true
            }
            RowLayout {
                Button {
                    text: "RSS"
                    onClicked: {
                        rssFile.startSelector()
                    }
                }
                Button {
                    text: "Add all"
                    enabled: rssModel.count>0
                    onClicked: {
                        let i;
                        for (i=0;i<rssModel.count;i++) {
                            const item={ "topic": rssModel.get(i).title, "msg": html.stripTags(rssModel.get(i).description) }
                            l3window.addNewsItem(item)
                        }
                    }
                }
                Label {
                    text: "RSS: "+newsFeedList.count
                }
            }
        }
    }
    
    XmlListModel {
        id: rssModel
        query: "/rss/channel/item"
        
        XmlRole { name: "title"; query: "title/string()"; }
        XmlRole { name: "description"; query: "description/string()"; }
        
        onStatusChanged: {
            switch (status) {
            case XmlListModel.Ready:
                
                break;
            case XmlListModel.Error:
                console.debug(errorString())
                break;
            }
        }
    }
    
    Component {
        id: rssItemModel
        ItemDelegate {
            width: ListView.view.width
            height: c.height
            ColumnLayout {
                id: c
                spacing: 2
                Text {
                    text: title;
                    font.bold: true;
                    maximumLineCount: 1;
                    elide: Text.ElideRight
                }
                Text {
                    text: description;
                    wrapMode: Text.Wrap;
                    maximumLineCount: 2;
                    elide: Text.ElideRight
                }
            }
            onClicked: {
                newsFeedList.currentIndex=index;
                newsKeyword.text=rssModel.get(index).title
                newsBody.text=html.stripTags(rssModel.get(index).description)
            }
            onDoubleClicked: {
                const news=rssModel.get(index)
                const item={ "topic": news.title, "msg": html.stripTags(news.description) }
                l3window.addNewsItem(item)
            }
        }
    }
    
    Component {
        id: newsEditorDelegate
        ItemDelegate {
            width: ListView.view.width
            height: c.height
            highlighted: ListView.isCurrentItem
            ColumnLayout {
                id: c
                width: parent.width
                Text {
                    text: topic;
                    font.bold: true;
                    maximumLineCount: 1;
                    elide: Text.ElideRight
                }
                Text {
                    text: msg;
                    wrapMode: Text.Wrap;
                }
            }
            onClicked: {
                console.debug(index)
                ListView.view.currentIndex=index;
            }
            onDoubleClicked: {
                newsKeyword.text=ListView.view.model.get(index).topic
                newsBody.text=ListView.view.model.get(index).msg
            }
        }
    }
    
    TextSelector {
        id: rssFile
        filter: [ "*.xml" ]
        onFileSelected: {
            rssModel.source=src
        }
    }
    
    Drawer {
        id: telepromptDrawer
        dragMargin: 0
        width: parent.width/1.5
        height: parent.height        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 8

            ColumnLayout {
                id: telepromptItemMessage
                Layout.alignment: Qt.AlignTop
                Layout.fillHeight: true
                Layout.fillWidth: true

                ScrollView {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.maximumHeight: telepromptDrawer.height/6
                    ScrollBar.vertical.policy: ScrollBar.AlwaysOn
                    background: Rectangle {
                        border.color: "black"
                        border.width: 1
                    }
                    TextArea {
                        id: telepromptTextMsg
                        placeholderText: "Write a telepromt message here"
                        selectByKeyboard: true
                        selectByMouse: true
                        textFormat: TextEdit.PlainText
                        wrapMode: TextEdit.Wrap
                    }
                }
                RowLayout {
                    Switch {
                        id: telepromptMsgSwitch
                        Layout.alignment: Qt.AlignLeft
                        text: "Display message"
                        checked: true
                        onCheckedChanged: {
                            if (checked)
                                tpwindow.setMessage(telepromptTextMsg.text)
                            else
                                tpwindow.setMessage("")
                        }
                    }
                    Button {
                        text: "Update"
                        enabled: telepromptMsgSwitch.checked && telepromptTextMsg.length>0
                        onClicked: {
                            tpwindow.setMessage(telepromptTextMsg.text)
                        }
                    }
                    Button {
                        text: "Send"
                        enabled: telepromptMsgSwitch.checked && telepromptTextMsg.length>0
                        onClicked: {
                            tpwindow.setMessage(telepromptTextMsg.text)
                            telepromptTextMsg.text=""
                        }
                    }
                }
            }
            
            ScrollView {
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.minimumHeight: gl.height/3
                Layout.maximumHeight: gl.height/2
                ScrollBar.vertical.policy: ScrollBar.AlwaysOn
                background: Rectangle {
                    border.color: "black"
                    border.width: 1
                }
                TextArea {
                    id: textPrompter
                    placeholderText: "Teleprompt text here"
                    selectByKeyboard: true
                    selectByMouse: true
                    textFormat: TextEdit.PlainText
                    wrapMode: TextEdit.WordWrap
                }
            }
            
            RowLayout {
                spacing: 8
                Switch {
                    id: telepromptMirror
                    Layout.alignment: Qt.AlignLeft
                    text: "Mirror"
                    checked: false
                }
                Switch {
                    id: telepromptFlip
                    Layout.alignment: Qt.AlignLeft
                    text: "Flip"
                    checked: false
                }
                SpinBox {
                    id: lineSpeed
                    from: 1
                    to: 10
                    stepSize: 1
                    value: 8
                    onValueChanged: {
                        tpwindow.lineSpeed=value/10.0
                    }
                    wheelEnabled: true
                }
                SpinBox {
                    from: 18
                    to: 128
                    value: 72
                    onValueChanged: {
                        tpwindow.fontSize=value;
                    }
                    wheelEnabled: true
                }
            }
            
            RowLayout {
                spacing: 8
                Button {
                    text: "Update"
                    onClicked: {
                        tpwindow.telepromptSetText(textPrompter.text)
                    }
                }
                Button {
                    text: "Start"
                    enabled: !tpwindow.active
                    onClicked: {
                        tpwindow.telepromptStart();
                    }
                }
                Button {
                    text: "Stop"
                    enabled: tpwindow.active
                    onClicked: {
                        tpwindow.telepromptStop();
                    }
                }
                Button {
                    text: "Pause"
                    enabled: tpwindow.active && !tpwindow.paused
                    onClicked: {
                        tpwindow.telepromptPause();
                    }
                }
                Button {
                    text: "Resume"
                    enabled: tpwindow.active && tpwindow.paused
                    onClicked: {
                        tpwindow.telepromptResume();
                    }
                }
                Button {
                    text: "Reset"
                    enabled: tpwindow.active
                    onClicked: {
                        tpwindow.telepromptStop();
                    }
                }
            }
            
            Slider {
                Layout.fillWidth: true
                id: telePromptPos
                from: 0
                to: tpwindow.promptHeight
                value: tpwindow.promptPos
                onValueChanged: {
                    if (pressed) {
                        tpwindow.telepromptSetPosition(value)
                    }
                }
            }
        }
    }
    
    ListModel {
        id: l3ModelFinal
    }

    // XML Loader model
    LowerThirdModel {
        id: l3Model
        source: "persons.xml"
        onLoaded: {
            copyToListModel(l3ModelFinal)
        }
    }
    
    IrcSource {
        id: irc
        channel: ircChannel.text
        channelKey: ircChannelKey.text
        host: ircHostname.text
        nickName: ircNick.text
        password: ircPassword.text
        secure: ircSecure.checked
    }
    
    Timer {
        id: timerGeneric
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            var date = new Date;
            timeCurrent.text=Qt.formatTime(date, "hh:mm:ss");
        }
    }
    
    Ticker {
        id: ticker
        onZero: {            
            stop();
            // xxx: add option to hide when zero
            // xxx: add option to play a sound when zero
        }
    }
    
    Ticker {
        id: tickerUp
    }
    
    ButtonGroup {
        id: l3delegateButtonGroupLeft
    }
    
    ButtonGroup {
        id: l3delegateButtonGroupRight
    }
    
    Component {
        id: l3delegate
        ItemDelegate {
            id: l3id
            width: ListView.view.width
            height: r.height
            RowLayout {
                id: r
                width: parent.width
                ColumnLayout {
                    id: c
                    spacing: 4
                    Layout.fillWidth: true
                    Layout.preferredWidth: parent.width/1.5
                    Text { text: primary; font.pixelSize: 14 }
                    Text { text: secondary; font.pixelSize: 12 }
                }
                RadioButton {
                    text: "L"
                    Layout.fillWidth: false
                    Layout.preferredWidth: parent.width/5
                    ButtonGroup.group: l3delegateButtonGroupLeft
                    onCheckedChanged: {
                        if (checked)
                            l3id.ListView.view.currentIndexLeft=index;
                    }
                }
                RadioButton {
                    text: "R"
                    Layout.fillWidth: false
                    Layout.preferredWidth: parent.width/5
                    ButtonGroup.group: l3delegateButtonGroupRight
                    onCheckedChanged: {
                        if (checked)
                            l3id.ListView.view.currentIndexRight=index;
                    }
                }
            }
            onClicked: {
                ListView.view.currentIndex=index;
            }
            onDoubleClicked: {
                ListView.view.currentIndex=index;
                l3window.lthirdLeft.show();
            }
        }
    }
    
    GridLayout {
        id: gl
        anchors.fill: parent
        columns: 2
        rowSpacing: 4
        columnSpacing: 4
        anchors.margins: 4
        
        // 1x1
        ColumnLayout {
            id: itemMessage
            Layout.alignment: Qt.AlignTop
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.maximumWidth: gl.width/2
            
            ScrollView {
                Layout.fillHeight: true
                Layout.fillWidth: true
                ScrollBar.vertical.policy: ScrollBar.AlwaysOn
                Layout.minimumHeight: gl.height/7
                Layout.maximumHeight: gl.height/6
                background: Rectangle {
                    border.color: "black"
                    border.width: 1
                }
                TextArea {
                    id: textMsg
                    placeholderText: "Write a message for the talent here"
                    selectByKeyboard: true
                    selectByMouse: true
                    textFormat: TextEdit.PlainText
                    wrapMode: TextEdit.Wrap
                }
            }
            RowLayout {
                Switch {
                    id: msgSwitch
                    Layout.alignment: Qt.AlignLeft
                    text: "Display message"
                    onCheckedChanged: {
                        if (checked)
                            l3window.setMessage(textMsg.text)
                        else
                            l3window.setMessage("")
                    }
                }
                Button {
                    text: "Update"
                    enabled: msgSwitch.checked
                    onClicked: {
                        l3window.setMessage(textMsg.text)
                    }
                }
                Button {
                    text: "Send"
                    enabled: msgSwitch.checked
                    onClicked: {
                        l3window.setMessage(textMsg.text)
                        textMsg.text=""
                    }
                }
                MenuAlignment {
                    window: l3window;
                    item: l3window.txtMessage
                }
            }            
        }
        
        // 2x1
        ColumnLayout {
            id: itemSelector
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.maximumWidth: gl.width/2
            Layout.alignment: Qt.AlignTop
            ListView {
                id: l3selector
                model: l3ModelFinal
                delegate: l3delegate
                clip: true
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: gl.height/6
                Layout.maximumHeight: gl.height/3
                highlight: Rectangle { color: "lightblue" }
                
                property int currentIndexLeft: -1;
                property int currentIndexRight: -1;
                
                onCurrentIndexLeftChanged: {
                    const data=model.get(currentIndexLeft);
                    l3window.lthirdLeft.setDetails(data.primary, data.secondary, data.topic, data.image)
                }
                
                onCurrentIndexRightChanged: {
                    const data=model.get(currentIndexRight);
                    l3window.lthirdRight.setDetails(data.primary, data.secondary, data.topic, data.image)
                }

                ScrollIndicator.vertical: ScrollIndicator {}
            }
            
            RowLayout {
                Button {
                    text: "Previous"
                    onClicked: l3selector.decrementCurrentIndex()
                }
                Button {
                    text: "Next"
                    onClicked: l3selector.incrementCurrentIndex()
                }
                Label {
                    text: 1+l3selector.currentIndex+"/"+l3selector.count
                }
                SpinBox {
                    id: delayTime
                    from: 1
                    to: 10
                    stepSize: 1
                    value: 5
                }
                Button {
                    text: "Show L"
                    enabled: l3selector.currentIndexLeft>-1
                    onClicked: {
                        l3window.lthirdLeft.show();
                    }
                }
                Button {
                    text: "Show R"
                    enabled: l3selector.currentIndexRight>-1
                    onClicked: {
                        l3window.lthirdRight.show();
                    }
                }
                Button {
                    text: "Show LR"
                    enabled: l3selector.currentIndexRight>-1 && l3selector.currentIndexLeft>-1
                    onClicked: {
                        l3window.lthirdLeft.show();
                        l3window.lthirdRight.show();
                    }
                }
            }
        }
        
        // 1x2
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.maximumWidth: gl.width/2
            RowLayout {
                Switch {
                    id: showTime
                    Layout.alignment: Qt.AlignLeft
                    text: "Time"
                    checked: true
                    onCheckedChanged: settings.setSettings("timers/time", checked)
                }
                Text {
                    id: timeCurrent
                    Layout.fillWidth: true
                    text: "00:00:00"
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 18
                }                
                MenuAlignment {
                    window: l3window;
                    item: l3window.txtTime
                }
                
            }
            RowLayout {
                Switch {
                    id: showCounter
                    Layout.alignment: Qt.AlignLeft
                    text: "Counter"
                    checked: false
                    onCheckedChanged: settings.setSettings("timers/counter", checked)
                }
                Text {
                    id: timeCount
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: formatSeconds(tickerUp.seconds)
                    font.pixelSize: 18
                    color: tickerUp.active ? "red" : "green"
                    MouseArea {
                        anchors.fill: parent
                        onPressAndHold: {
                            tickerUp.reset()
                        }
                        onDoubleClicked: {
                            if (!tickerUp.active)
                                tickerUp.start()
                            else
                                tickerUp.stop()
                        }
                    }
                }
                MenuAlignment {
                    window: l3window;
                    item: l3window.txtUp
                }
            }
            RowLayout {
                Switch {
                    id: showCountdown
                    Layout.alignment: Qt.AlignLeft
                    text: "Down"
                    checked: false
                    onCheckedChanged: settings.setSettings("timers/countdown", checked)
                }
                Text {
                    id: timeCountdown
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: formatSeconds(ticker.countdown)
                    font.pixelSize: 18
                    color: ticker.active ? "red" : "green"
                    MouseArea {
                        anchors.fill: parent
                        onDoubleClicked: {
                            if (!showCountdown.checked)
                                showCountdown.checked=true
                            if (!ticker.active)
                                ticker.start()
                            else
                                ticker.stop()
                        }
                        onPressAndHold: {
                            ticker.setCountdownSeconds(0);
                        }
                        onWheel: {
                            wheel.accepted=true
                            const d=wheel.angleDelta.y<0 ? -1 : 1;
                            if (wheel.modifiers & Qt.ControlModifier) {
                                ticker.addCountdownSeconds(60*d);
                            } else if (wheel.modifiers & Qt.AltModifier) {
                                ticker.addCountdownSeconds(1*d);
                            } else {
                                ticker.addCountdownSeconds(10*d);
                            }
                        }
                    }
                }                
                Button {
                    text: "+10s"
                    onClicked: ticker.addCountdownSeconds(10);
                }
                Button {
                    text: "+1m"
                    onClicked: ticker.addCountdownSeconds(60);
                }
                Button {
                    text: "+5m"
                    onClicked: ticker.addCountdownSeconds(5*60);
                }
                Button {
                    text: "+15m"
                    onClicked: ticker.addCountdownSeconds(15*60);
                }
                Button {
                    text: "0"
                    onClicked: ticker.setCountdownSeconds(0);
                }
                MenuAlignment {
                    window: l3window;
                    item: l3window.txtCountdown
                }
            }
            RowLayout {
                Switch {
                    id: showAnimation
                    Layout.alignment: Qt.AlignLeft
                    text: "Animation"
                    checked: false
                }
                Switch {
                    id: activeAnimation
                    Layout.alignment: Qt.AlignLeft
                    text: "Active"
                    checked: true
                }
                ComboBox {
                    id: animationSelector
                    model: [ "Snow" ]
                }
            }
            RowLayout {
                Button {
                    text: "Start"
                    onClicked: ticker.start()
                }
                Button {
                    text: "Stop"
                    onClicked: ticker.stop()
                }
                DelayButton {
                    text: "Reset"
                    delay: 2000
                    onActivated: {
                        ticker.reset()
                        checked=false;
                    }
                }
            }
        }
        // 2x2
        ColumnLayout {
            TabBar {
                id: mediaBar
                TabButton {
                    text: "Media"
                }
                TabButton {
                    text: "Input"
                }
            }
            Pane {
                Layout.fillWidth: true
                SwipeView {
                    clip: true
                    currentIndex: mediaBar.currentIndex
                    anchors.fill: parent
                    MediaController {
                        vo: l3window.mediaPlayerOutput
                    }
                    MediaController {
                        vo: l3window.videoInputOutput
                    }
                }
            }
        }
    }
    
    MqttClient {
        id: mqttClient
        clientId: "cuteproduction"
        hostname: "127.0.0.1"
        // port: "1883"
        
        readonly property string topicBase: "cuteproduction/0/"
        
        onConnected: {
            console.debug("MQTT: Connected")
            
            publishActive(1)
            setWillTopic(topicBase+"active")
            setWillMessage(0)
            
            subscribeTopic(topicBase+"message", showMessage, MqttSubscription.String)
            subscribeTopic(topicBase+"subtitle", showSubtitle, MqttSubscription.String)
            subscribeTopic(topicBase+"chat", addChatMessage, MqttSubscription.JsonObject)            
        }
        
        onDisconnected: {
            console.debug("MQTT: Disconnected")
        }
        
        onErrorChanged: console.debug("MQTT: Error "+ error)
        onStateChanged: console.debug("MQTT: State "+state)
        //onPingResponseReceived: console.debug("MQTT: Ping")
        //onMessageSent: console.debug("MQTT: Sent "+id)
        
        function subscribeTopic(topic, cb, type) {
            console.debug(MqttSubscription.String)
            let s=mqttClient.subscribe(topic, 0)
            s.setType(type)
            s.messageReceived.connect(cb)
        }

        function publishActive(i) {
            publish(topicBase+"active", i, 1, true)
        }
    }
    
    function showMessage(str) {
        l3window.setMessage(str)
    }

    function showSubtitle(str) {
        l3window.setSubtitle(str)
    }

    function addChatMessage(data) {        
        l3window.addMessageLeft(data.topic, data.message);
    }
}
