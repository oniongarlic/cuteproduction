import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.15
import QtQuick.XmlListModel 2.15
//import QtQuick3D 1.15

import org.tal 1.0

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
                    mirror: telepromptMirror.checked
                    flip: telepromptFlip.checked
                }

                RowLayout {
                    id: tpStatusBar
                    Slider {
                        Layout.fillWidth: true
                        from: 0
                        to: tpwindow.promptHeight
                        value: tpwindow.promptPos
                    }
                }
            }

            function telepromptStart() {
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
    }
    
    Component {
        id: aws
        Window {
            id: secondaryWindow            
            title: "Information"
            minimumWidth: spanWindow ? Screen.desktopAvailableWidth : 800
            minimumHeight: spanWindow ? Screen.desktopAvailableHeight : 480
            width: 1024
            height: 720
            modality: Qt.NonModal
            transientParent: null
            
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
            
            Rectangle {
                id: background
                anchors.fill: parent
                color: bgBlack.checked ? "black" : bgGreen.checked ? "green" : "blue"
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

            ListModel {
                id: msgModelLeft
            }
            ListModel {
                id: msgModelRight
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
                ItemDelegate {
                    width: parent.width
                    height: c.height+32
                    background: Rectangle {
                        color: "#b5f1ff"
                        radius: 8
                        border.color: "#2065c6"
                    }

                    ColumnLayout {
                        id: c
                        spacing: 4
                        width: parent.width
                        Text {
                            text: primary;
                            maximumLineCount: 1
                            Layout.fillWidth: true
                            Layout.margins: 8
                            elide: Text.ElideRight
                            font.pointSize: 14
                            textFormat: Text.PlainText
                            wrapMode: Text.NoWrap
                        }
                        Text {
                            Layout.fillWidth: true
                            Layout.margins: 8
                            text: secondary;
                            textFormat: Text.PlainText
                            font.pointSize: 12
                            elide: Text.ElideRight
                            maximumLineCount: 6
                            wrapMode: Text.Wrap
                        }
                    }
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
                    // highlight: Rectangle { color: "lightblue" }
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

            Timer {
                id: tickerTimer
                interval: 100
                running: newsTicker.visible
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

            ListModel {
                id: tickerModel
            }

            function clearNews() {
                tickerModel.clear()
            }

            function addNewsItem(item) {
                tickerModel.append(item)
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

            ParticleAnimation {
                id: particle
                running: showAnimation.checked
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
                    onClicked: {
                        const item={ "topic": newsKeyword.text, "msg": newsBody.text }
                        l3window.addNewsItem(item)
                        newsKeyword.clear()
                        newsBody.clear()
                        // newsDrawer.close()
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
            Label {
                text: "RSS: "+newsFeedList.count
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
                Text { text: title;
                    font.bold: true;
                    maximumLineCount: 1;
                    elide: Text.ElideRight
                }
                Text { text: description;
                    wrapMode: Text.Wrap;
                    maximumLineCount: 2;
                    elide: Text.ElideRight
                }
            }
            onClicked: {
                newsFeedList.currentIndex=index;
                newsKeyword.text=rssModel.get(index).title
                newsBody.text=rssModel.get(index).description
            }
        }
    }

    Component {
        id: newsEditorDelegate
        ItemDelegate {
            width: ListView.view.width
            height: c.height
            ColumnLayout {
                id: c
                Text { text: topic;  }
                Text { text: msg; }
            }
            onClicked: {
                newsEditorList.currentIndex=index;
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
            }
            RowLayout {
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
