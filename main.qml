import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.15
import QtMultimedia 5.15
import QtQuick.XmlListModel 2.15
//import QtQuick3D 1.15

import org.tal 1.0

import "windows"
import "selectors"

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
    color: "white"
    
    property Window l3window;
    property Window alphawindow;
    property Window tpwindow;

    Component.onCompleted: {
        oflags=flags;
        console.debug("Screens: " + Qt.application.screens.length)
        for(var i = 0;i < Qt.application.screens.length;i ++) {
            console.debug(i)
        }

        console.debug(Screen.desktopAvailableWidth)
        console.debug(Screen.desktopAvailableHeight)

        l3window=aws.createObject(main, { screen: Qt.application.screens[1], visible: true });
        tpwindow=tpw.createObject(main, { screen: Qt.application.screens[2], visible: false });

        if (Qt.application.screens.length>2) {

        }
    }

    property string primary: ""
    property string secondary: ""

    property int counter: 0

    function formatSeconds(s) {
        var h = Math.floor(s / 3600);
        s %= 3600;
        var m = Math.floor(s / 60);
        var ss = s % 60;
        return [h,m,ss].map(v => v < 10 ? "0" + v : v).join(":")
    }

    signal textFileResponse(string text)

    function readLocalTextFile(uri) {
        var xhr = new XMLHttpRequest;
        console.debug(uri)
        xhr.open("GET", uri);
        xhr.onreadystatechange = function() {
            if (xhr.readyState == XMLHttpRequest.DONE) {
                textFileResponse(xhr.responseText)
            }
        };
        xhr.send();
    }

    onTextFileResponse: {
        textPrompter.text=text
    }

    Component {
        id: tpw
        TelepromptWindow {
            id: teleWindow
            mirror: telepromptMirror.checked
            flip: telepromptFlip.checked
        }
    }
    
    Component {
        id: aws
        OutputWindow {
            id: secondaryWindow
            tickerItemsVisible: menuTickerFullWidth.checked ? 1 : 4
            mediaPlayer: mp
        }
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
                text: "Full screen (Teleprompt)"
                checkable: true
                checked: tpwindow.visibility==Window.FullScreen ? true : false
                onCheckedChanged: tpwindow.visibility=!checked ? Window.Windowed : Window.FullScreen
            }
        }

        Menu {
            title: "Message"
            MenuItem {
                text: "Paste"
                enabled: textMsg.canPaste
                onClicked: textMsg.paste()
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
            title: "Thirds"
            MenuItem {
                text: "Open..."
                onClicked: tsf.startSelector();
            }
            MenuItem {
                text: "Add.."
                onClicked: {
                    thirdsDrawer.open()
                }
            }
            MenuSeparator {

            }
            MenuItem {
                text: "Clear"
                onClicked: {
                    l3Model.source=""
                }
            }
        }
        Menu {
            title: "Prompt"
            MenuItem {
                text: "Open..."
                enabled: true
                onClicked: tsftp.startSelector();
            }
            MenuItem {
                text: "Paste"
                enabled: textPrompter.canPaste
                onClicked: {
                    textPrompter.paste()
                    tpwindow.telepromptSetText(textPrompter.text)
                }
            }
            MenuSeparator {

            }
            MenuItem {
                text: "Clear"
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
        }

        Menu {
            title: "News"
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
                text: "Clear"
                onClicked: {
                    l3window.clearNews()
                }
            }
            MenuItem {
                text: "Add.."
                onClicked: {
                    newsDrawer.open()
                }
            }
        }

        Menu {
            title: "Media"

            MenuItem {
                text: "Manage"
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
                text: "Add URL"
                onClicked: {
                    usd.open()
                }
            }

            MenuItem {
                text: "Open playlist"
                onClicked: {
                    plist.load("file:///tmp/playlist.m3u8", "m3u8")
                }
            }

            MenuItem {
                text: "Save playlist"
                onClicked: {
                    plist.save("file:///tmp/playlist.m3u8", "m3u8")
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
            title: "Background"

            MenuItem {
                id: bgBlack
                text: "Black"
                checkable: true
                checked: true
                autoExclusive: true
            }
            MenuItem {
                id: bgGreen
                text: "Green"
                checkable: true
                autoExclusive: true
            }
            MenuItem {
                id: bgBlue
                text: "Blue"
                checkable: true
                autoExclusive: true
            }
        }
    }

    TextSelector {
        id: tsftp
        filter: [ "*.txt" ]
        onFileSelected: {
            readLocalTextFile(src)
        }
    }

    TextSelector {
        id: tsf
        filter: [ "*.xml" ]
        onFileSelected: {
            l3Model.source=src
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

    Drawer {
        id: mediaDrawer
        dragMargin: 0
        width: parent.width/2
        height: parent.height
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
                Dial {
                    id: volumeDial
                    from: 0
                    to: 100
                    value: 100
                }
                CheckBox {
                    id: checkMuted
                    text: "Mute"
                    checked: mp.muted
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
        id: thirdsDrawer
        dragMargin: 0
        width: parent.width/2
        height: parent.height
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 8
            TextField {
                id: textl3Primary
                Layout.fillWidth: true
                placeholderText: "Primary"
                selectByMouse: true
            }
            TextField {
                id: textl3Secondary
                Layout.fillWidth: true
                placeholderText: "Secondary"
                selectByMouse: true
            }
            RowLayout {
                spacing: 8
                Button {
                    text: "Add"
                    onClicked: {
                        const item={ "topic": textl3Primary.text, "msg": textl3Secondary.text }
                        l3window.addNewsItem(item)
                    }
                }
                Button {
                    text: "Clear"
                    onClicked: {
                        textl3Primary.clear()
                        textl3Secondary.clear()
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
        width: parent.width/2
        height: parent.height
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
            TextArea {
                id: newsBody
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.maximumHeight: newsKeyword.height*4
                placeholderText: "Body"
                selectByKeyboard: true
                selectByMouse: true
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
                Button {
                    text: "RSS"
                    onClicked: {
                        rssFile.startSelector()
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

    ListModel {
        id: l3ModelCustom
    }

    XmlListModel {
        id: l3Model
        query: "/thirds/item"
        source: "persons.xml"

        XmlRole { name: "primary"; query: "primary/string()"; }
        XmlRole { name: "secondary"; query: "secondary/string()"; }
        XmlRole { name: "topic"; query: "topic/string()"; }
        XmlRole { name: "image"; query: "image/string()"; }

        onStatusChanged: {
            switch (status) {
            case XmlListModel.Ready:
                //msg.text="T"
                break;
            case XmlListModel.Error:
                console.debug(errorString())
                break;
            }
        }
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
    }

    Component {
        id: l3delegate
        ItemDelegate {
            width: ListView.view.width
            height: c.height
            ColumnLayout {
                id: c
                Text { text: primary; font.pointSize: 14 }
                Text { text: secondary; font.pointSize: 12 }
            }
            onClicked: {
                l3selector.currentIndex=index;
            }
        }
    }

    GridLayout {
        id: gl
        anchors.fill: parent
        columns: 2
        rowSpacing: 8
        columnSpacing: 8
        anchors.margins: 8

        ColumnLayout {
            id: itemMessage
            Layout.alignment: Qt.AlignTop
            Layout.fillHeight: true
            Layout.fillWidth: true

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
                    wrapMode: TextEdit.WordWrap
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
            }
            Frame {
                Layout.fillWidth: true
                Layout.fillHeight: true
                ColumnLayout {
                    anchors.fill: parent
                    TextField {
                        id: bP
                        Layout.fillWidth: true
                        selectByMouse: true
                    }
                    TextArea {
                        id: bS
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        selectByKeyboard: true
                        selectByMouse: true
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
                            enabled: bP.length>0
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

        ColumnLayout {
            id: itemSelector
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignTop
            ListView {
                id: l3selector
                model: l3Model
                delegate: l3delegate
                clip: true
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: gl.height/6
                Layout.maximumHeight: gl.height/3
                highlight: Rectangle { color: "lightblue" }
                onCurrentIndexChanged: {
                    main.primary=model.get(currentIndex).primary
                    main.secondary=model.get(currentIndex).secondary
                }
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
                    text: "Show"
                    onClicked: {
                        l3window.show();
                    }
                }
            }
        }

        ColumnLayout {
            RowLayout {
                Switch {
                    id: showTime
                    Layout.alignment: Qt.AlignLeft
                    text: "Time"
                    checked: true
                }
                Text {
                    id: timeCurrent
                    Layout.fillWidth: true
                    text: "00:00:00"
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 48
                }
            }
            RowLayout {
                Switch {
                    id: showCounter
                    Layout.alignment: Qt.AlignLeft
                    text: "Counter"
                    checked: false
                }
                Text {
                    id: timeCount
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: formatSeconds(ticker.seconds)
                    font.pixelSize: 32
                }
            }
            RowLayout {
                Switch {
                    id: showCountdown
                    Layout.alignment: Qt.AlignLeft
                    text: "Down"
                    checked: false
                }
                Text {
                    id: timeCountdown
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: formatSeconds(ticker.countdown)
                    font.pixelSize: 32
                }
            }
            RowLayout {
                Switch {
                    id: showAnimation
                    Layout.alignment: Qt.AlignLeft
                    text: "Animation"
                    checked: false
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
                Button {
                    text: "+1min"
                    onClicked: ticker.addCountdownSeconds(60);
                }
                Button {
                    text: "+5min"
                    onClicked: ticker.addCountdownSeconds(5*60);
                }
                Button {
                    text: "+15min"
                    onClicked: ticker.addCountdownSeconds(15*60);
                }
                Button {
                    text: "0"
                    onClicked: ticker.setCountdownSeconds(0);
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

        ColumnLayout {
            id: cl2
            ScrollView {
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.minimumHeight: gl.height/7
                Layout.maximumHeight: gl.height/6
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
                Switch {
                    id: telepromptShow
                    Layout.alignment: Qt.AlignLeft
                    text: "teleprompt"
                    checked: true
                }
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
                }
            }

            RowLayout {
                Button {
                    text: "Update"
                    onClicked: {
                        tpwindow.telepromptSetText(textPrompter.text)
                    }
                }
                Button {
                    text: "Start"
                    onClicked: {
                        tpwindow.telepromptStart();
                    }
                }
                Button {
                    text: "Stop"
                    onClicked: {
                        tpwindow.telepromptStop();
                    }
                }
            }
            RowLayout {
                Button {
                    text: "Pause"
                    onClicked: {
                        tpwindow.telepromptPause();
                    }
                }
                Button {
                    text: "Resume"
                    onClicked: {
                        tpwindow.telepromptResume();
                    }
                }
                Button {
                    text: "Reset"
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
}
