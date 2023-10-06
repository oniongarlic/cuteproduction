import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia
import QtQml.XmlListModel
import QtQuick.Dialogs

import org.tal 1.0
import org.tal.cutehyper 1.0
import org.tal.mqtt 1.0

import org.tal.trdparty

import "windows"
import "selectors"
import "messaging"
import "components"
import "models"
import "drawers"

ApplicationWindow {
    id: main
    width: 1024
    height: 768
    minimumWidth: 800
    minimumHeight: 480
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

    property var date;
    
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
        mp.videoOutput=l3window.mediaPlayerOutput.vo
        videoCaptureSession.videoOutput=l3window.videoInputOutput.vo

        console.debug("Loading settings...")
        loadSettings()
        console.debug("...done")
        
        mqttClient.connectToHost();
    }
    
    onClosing: {
        cuteQuit();
    }

    function cuteQuit() {
        l3window.destroy()
        tpwindow.destroy()
        maskwindow.destroy()

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
            objectName: "teleprompt"
            onScreenChanged: {
                console.debug("TelepromptWindow is now: "+screen.name)
                settings.setSettingsStr("windows/teleprompt", screen.name)
            }
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
            tickerVisible: main.newsTickerShow
            newsPanelShow: main.newsPanelShow

            mediaPlayer: mp
            
            onTickerItemsVisibleChanged: settings.setSettings("ticker/items", tickerItemsVisible)
            onTickerVisibleChanged: settings.setSettings("ticker/visible", tickerVisible)
            onNewsPanelVisibleChanged: settings.setSettings("ticker/panelvisible", newsPanelVisible)
        }
    }

    property bool newsTickerShow: false
    property bool newsPanelShow: false
    
    function loadSettings() {
        newsTickerShow=settings.getSettingsBool("ticker/visible", false);
        menuTickerFullWidth.checked=settings.getSettingsInt("ticker/items", 1, 1, 4)===1 ? true : false;
        newsPanelShow=settings.getSettingsBool("ticker/panelvisible", false);
    }
    
    menuBar: MenuBar {
        Menu {
            title: "File"
            MenuItem {
                text: "MQTT"
                enabled: mqttClient.state==MqttClient.Disconnected
                onClicked:mqttClient.connectToHost();
            }
            MenuSeparator {
                
            }
            MenuItem {
                text: "Quit"
                onClicked: cuteQuit()
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
                text: "Manage.."
                onClicked: {
                    thirdsDrawer.open()
                }
            }
            MenuItem {
                text: "Open..."
                onClicked: tsf.startSelector();
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
                id: menuPanelVisible
                text: "Panel visible"
                checkable: true
                checked: newsPanelShow
                onCheckedChanged: newsPanelShow=checked
            }
            MenuItem {
                id: menuTickerVisible
                text: "Ticker visible"
                checkable: true
                checked: newsTickerShow
                onCheckedChanged: newsTickerShow=checked
            }
            MenuItem {
                id: menuTickerFullWidth
                text: "Full width title"
                checkable: true
                checked: false
            }
            MenuSeparator {

            }
            MenuItem {
                text: "Align Top"
                onClicked: l3window.setTickerPosition(Qt.AlignTop)
            }
            MenuItem {
                text: "Align Bottom"
                onClicked: l3window.setTickerPosition(Qt.AlignBottom)
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
        }
        Menu {
            title: "Video input"
            enabled: l3window.hasVideoInput
            MenuItem {
                text: "Start"
                enabled: !videoInput.active
                onClicked: {
                    videoInput.start()
                }
            }
            MenuItem {
                text: "Stop"
                enabled: videoInput.active
                onClicked: {
                    videoInput.stop();
                }
            }
            MenuItem {
                text: "Select"
                enabled: !videoInput.active && videoInputsModel.count>0
                onClicked: {
                    cameraSelector.open()
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
                value: dialogColor.selectedColor
                checkable: true
                ButtonGroup.group: backgroundGroup
            }
            ColorMenuItem {
                id: bgCustomChoose
                text: "Select custom..."
                checkable: true
                value: dialogColor.selectedColor
                ButtonGroup.group: backgroundGroup
                onClicked: {
                    dialogColor.open()
                }
            }
            MenuSeparator {
                
            }
            ColorMenuItem {
                id: bgImage
                text: "Image"
                ButtonGroup.group: backgroundGroup
                enabled: image!=''
                checkable: true
                value: ''
                property string image;
                onClicked: {
                    l3window.setBackground('image', image);
                }
                Component.onCompleted: {
                    image=settings.getSettingsStr("background/image", '')
                }
                icon.source: image
                icon.width: 32
                icon.height: 32
            }
            MenuItem {
                id: bgImageChoose
                text: "Select Image..."
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
                    bgImage.image=''
                }
            }
        }
    }
    
    ButtonGroup {
        id: backgroundGroup
        property string currentValue: 'black';
        onClicked: (button) => {
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
            l3window.setBackground('custom', dialogColor.selectedColor);
            backgroundGroup.currentValue=dialogColor.selectedColor;
        }
        onRejected: {
            
        }
        Component.onCompleted: {
            dialogColor.selectedColor=settings.getSettingsStr("background/customColor", "yellow")
        }
        onSelectedColorChanged: {
            settings.setSettingsStr("background/customColor", selectedColor)
        }
    }
    
    TextSelector {
        id: tsimg
        filter: [ "*.jpg" ]
        onFileSelected: {
            l3window.setBackground('image', src)
            settings.setSettingsStr("background/image", src)
            bgImage.image=src;
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
        //selectExisting: false
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
        plist.next();
        mp.pause();
    }
    
    function previousMediaFile() {
        plist.previous();
        mp.pause();
    }
    
    function setMediaFile(i) {
        plist.currentIndex=i;
        mp.pause();
    }
    
    MediaSelector {
        id: ms
        
        onFileSelected: {
            plist.addItem(src)
            //mp.pause();
            //hs.setClips(plist.itemCount)
        }
        
        onFilesSelected: {
            plist.addItems(src)
            //hs.setClips(plist.itemCount)
        }
    }

    CaptureSession {
        id: videoCaptureSession
        camera: videoInput
    }

    Camera {
        id: videoInput
        cameraDevice: mediaDevices.defaultVideoInput
        onErrorOccurred: console.debug("CameraError: "+errorString)
        onActiveChanged: console.debug("CameraActive:"+active)
        onCameraDeviceChanged: console.debug(cameraDevice.id)
        onCameraFormatChanged: console.debug(cameraFormat.resolution)
        onSupportedFeaturesChanged: console.debug(supportedFeatures)
        Component.onCompleted: {
            console.debug(cameraDevice.id)
            console.debug(supportedFeatures)
            console.debug(cameraFormat.resolution)
        }
    }

    CameraSelectorPopup {
        id: cameraSelector
        model: videoInputsModel
        onCameraSelected: (deviceIndex) => {
                              videoInput.stop();
                              videoInput.cameraDevice=mediaDevices.videoInputs[deviceIndex]
                              videoFormats.updateVideoFormats(videoInput.cameraDevice)
                          }
    }

    CameraResolutionPopup {
        id: cameraResolutionSelector
        model: videoFormats
        onCameraResolutionSelected: {

        }
    }

    MediaDevices {
        id: mediaDevices
        onVideoInputsChanged: updateVideoInputs()
        onAudioInputsChanged: updateAudioInputs()
        onAudioOutputsChanged: updateAudioOutputs()

        property int videoInputCount: 0

        Component.onCompleted: {
            updateVideoInputs()
            updateAudioInputs()
            updateAudioOutputs()

            console.debug(defaultAudioOutput.description)
            console.debug(defaultAudioInput.description)
            console.debug(defaultVideoInput.description)
        }

        function updateAudioInputs() {
            for (var i=0;i<audioInputs.length;i++) {
                var vi=audioInputs[i]
                console.debug(i+" AudioInput:"+vi.id)
                console.debug(vi.description)
                console.debug(vi.isDefault)
                audioInputsModel.append(vi)
            }
        }

        function updateAudioOutputs() {
            for (var i=0;i<audioOutputs.length;i++) {
                var vi=audioOutputs[i]
                console.debug(i+" AudioOuput:"+vi.id)
                console.debug(vi.description)
                console.debug(vi.isDefault)
                audioOutputsModel.append(vi)
            }
        }

        function updateVideoInputs() {
            videoInputCount=videoInputs.length
            videoInputsModel.clear()
            console.debug("Video inputs: ")
            for (var i=0;i<videoInputs.length;i++) {
                var vi=videoInputs[i]
                console.debug(i+" VideoInput:"+vi.id)
                console.debug(vi.description)
                console.debug(vi.isDefault)
                var vf=vi.videoFormats
                console.debug("Supported formats")
                for (var f=0;f<vf.length;f++) {
                    console.debug(vf[f].maxFrameRate)
                    console.debug(vf[f].minFrameRate)
                    console.debug(vf[f].pixelFormat)
                    console.debug(vf[f].resolution)
                }
                videoInputsModel.append(vi)
            }
        }
    }

    ListModel {
        id: videoInputsModel
    }
    ListModel {
        id: videoFormats
        function updateVideoFormats(cameraDevice) {
            console.debug("Current camera, supported formats")
            clear();
            var vf=cameraDevice.videoFormats
            for (var f=0;f<vf.length;f++) {
                console.debug(vf[f].maxFrameRate)
                console.debug(vf[f].minFrameRate)
                console.debug(vf[f].pixelFormat)
                console.debug(vf[f].resolution)
                append(vf)
            }
        }
    }
    ListModel {
        id: audioInputsModel
    }
    ListModel {
        id: audioOutputsModel
    }
    
    MediaPlayer {
        id: mp
        loops: mediaDrawer.loop ? MediaPlayer.Infinite : 1
        audioOutput: AudioOutput {
            muted: mediaDrawer.muted
            volume: mediaDrawer.volume/100
        }

        onPositionChanged: {
            console.debug(position)
            //hs.setTimecode(position);
        }
        onDurationChanged: {
            console.debug(duration)
            //hs.setDuration(duration)
        }

        onMediaStatusChanged: {
            console.debug(mediaStatus)
        }

        onPlaybackStateChanged: {
            console.debug(playbackState)
            switch (playbackState) {
            case MediaPlayer.PlayingState:
                break;
            case MediaPlayer.PausedState:
                break;
            case MediaPlayer.StoppedState:
                break;
            }
        }
    }
    
    MediaPlaylistModel {
        id: plist
        onCurrentIndexChanged: {
            mp.source=get(currentIndex).source
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
            console.debug("HyperLOOP")
        }
    }
    
    MediaDrawer {
        id: mediaDrawer
        playlist: plist
        onPreviewChanged: {
            if (preview) {
                mp.videoOutput=previewVideo
            } else {
                mp.videoOutput=l3window.mediaPlayerOutput.vo
            }
        }
    }
    
    Drawer {
        id: chatDrawer
        dragMargin: 0
        width: parent.width/1.25
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
    
    IrcChatDrawer {
        id: ircDrawer
        ircSource: irc
    }
    
    ThirdsDrawer {
        id: thirdsDrawer
    }
    
    NewsDrawer {
        id: newsDrawer
        tickerModel: l3window.newsTickerModel
        panelModel: l3window.newsPanelModel
    }

    ClapperDrawer {
        id: clapper
        clapper: l3window.clapper
    }
    
    TelepromptDrawer {
        id: telepromptDrawer
        tpwindow: main.tpwindow
    }
    
    ListModel {
        id: l3ModelFinal
    }
    
    // XML Loader model
    LowerThirdModel {
        id: l3Model
        onLoaded: {
            copyToListModel(l3ModelFinal)
            if (source!='persons.xml')
                settings.setSettingsStr("thirds", source)
        }
        Component.onCompleted: {
            source=settings.getSettingsStr("thirds", "persons.xml")
        }
    }
    
    IrcSource {
        id: irc
    }
    
    Timer {
        id: timerGeneric
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            date = new Date;
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
                    //Layout.preferredWidth: parent.width/1.5
                    Layout.minimumWidth: parent.width/4
                    Layout.maximumWidth:  parent.width/1.25
                    Text { text: primary; font.bold: true; font.pixelSize: 14 }
                    Text { text: secondary; font.pixelSize: 12 }
                    Text { text: topic; font.pixelSize: 10; visible: text!='' }
                }
                RadioButton {
                    text: "L"
                    Layout.fillWidth: false
                    //Layout.preferredWidth: parent.width/5
                    ButtonGroup.group: l3delegateButtonGroupLeft
                    onCheckedChanged: {
                        if (checked)
                            l3id.ListView.view.currentIndexLeft=index;
                    }
                }
                RadioButton {
                    text: "R"
                    Layout.fillWidth: false
                    //Layout.preferredWidth: parent.width/5
                    ButtonGroup.group: l3delegateButtonGroupRight
                    onCheckedChanged: {
                        if (checked)
                            l3id.ListView.view.currentIndexRight=index;
                    }
                }
            }
            onClicked: {
                ListView.view.currentIndexLeft=index;
            }
            onDoubleClicked: {
                ListView.view.currentIndexLeft=index;
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

            RowLayout {
                id: rl11
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: gl.height/6
                ScrollView {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    //Layout.minimumWidth: rl11.width/2
                    //Layout.maximumWidth: rl11.width/1.5
                    ScrollBar.vertical.policy: ScrollBar.AlwaysOn
                    //Layout.minimumHeight: gl.height/7
                    //Layout.maximumHeight: gl.height/6
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
                GroupBox {
                    title: "Current message"
                    Layout.fillWidth: true
                    Layout.minimumHeight: gl.height/7
                    Layout.maximumHeight: gl.height/6
                    Layout.fillHeight: true
                    Layout.maximumWidth: rl11.width/2
                    Layout.alignment: Qt.AlignTop
                    Text {
                        id: messageCurrent
                        anchors.fill: parent
                        text: l3window.messageText
                        wrapMode: TextEdit.Wrap
                        textFormat: TextEdit.PlainText
                        maximumLineCount: 4
                        font.pixelSize: 12
                    }
                }
            }
            
            RowLayout {
                Switch {
                    id: msgSwitch
                    Layout.alignment: Qt.AlignLeft
                    text: "Display message"
                    onCheckedChanged: {
                        l3window.messageVisible=checked
                    }
                }
                Button {
                    text: "Update"
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
                        msgSwitch.checked=true
                    }
                }
                Button {
                    text: "Clear"
                    onClicked: {
                        l3window.setMessage("")
                    }
                }
                MenuAlignment {
                    window: l3window;
                    item: l3window.txtMessage
                }
            }
            RowLayout {
                Switch {
                    text: "QRCode"
                    checked: l3window.qrCode.show
                    onCheckedChanged: {
                        l3window.qrCode.show=checked
                    }
                }
                TextField {
                    id: qrcodeText
                    Layout.fillWidth: true
                    selectByMouse: true
                    placeholderText: "https://"
                    onAccepted: {
                        l3window.qrCode.url=text
                    }
                }
                Button {
                    text: "Paste"
                    enabled: qrcodeText.canPaste
                    onClicked: qrcodeText.paste()
                }
                Button {
                    text: "Clear"
                    enabled: qrcodeText.length>0
                    onClicked: qrcodeText.clear()
                }
                MenuAlignment {
                    window: l3window;
                    item: l3window.qrCode
                }
            }

            RowLayout {
                Switch {
                    text: "Clapper"
                    checked: l3window.clapperVisible
                    onCheckedChanged: {
                        l3window.clapperVisible=checked
                    }
                }

                Button {
                    text: "Clapper..."
                    onClicked: {
                        clapper.open()
                    }
                }
            }

            RowLayout {
                Switch {
                    id: switchNewsTickerShow
                    text: "NewsTicker"
                    checked: newsTickerShow
                    onCheckedChanged: {
                        newsTickerShow=checked
                    }
                }
                Switch {
                    id: switchNewsPanelShow
                    text: "NewsPanel"
                    checked: newsPanelShow
                    onCheckedChanged: {
                        newsPanelShow=checked
                    }
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
                            if (!ticker.active) {
                                if (!showCountdown.checked)
                                    showCountdown.checked=true
                                ticker.start()
                            } else {
                                ticker.stop()
                            }
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
            
            subscribeTopic(topicBase+"l3/left", triggerLowerThirdLeft, MqttSubscription.Bool)
            subscribeTopic(topicBase+"l3/right", triggerLowerThirdRight, MqttSubscription.Bool)
            subscribeTopic(topicBase+"l3/add", addLowerThird, MqttSubscription.JsonObject)
            
            subscribeTopic(topicBase+"ticker/show", triggerNewsTicker, MqttSubscription.Bool)
            subscribeTopic(topicBase+"ticker/clear", clearNewsTicker, MqttSubscription.Bool)
            subscribeTopic(topicBase+"ticker/add", addNewsTicker, MqttSubscription.JsonObject)
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
            let s=mqttClient.subscribe(topic)
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
    
    function triggerNewsTicker(v) {
        menuTickerVisible.checked=v
    }
    
    function clearNewsTicker(v) {
        l3window.newsTickerModel.clear();
    }
    
    function addNewsTicker(item) {
        l3window.newsTickerModel.append(item)
    }
    
    function addLowerThird(item) {
        l3ModelFinal.append(item)
    }
    
    function triggerLowerThirdLeft() {
        if (l3selector.currentIndexLeft>-1)
            l3window.lthirdLeft.show();
    }
    
    function triggerLowerThirdRight() {
        if (l3selector.currentIndexRight>-1)
            l3window.lthirdRight.show();
    }
    
    function addChatMessage(data) {
        l3window.addMessageLeft(data.topic, data.message);
    }
}
