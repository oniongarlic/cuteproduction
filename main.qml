import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.15
import QtQuick.XmlListModel 2.15
import QtQuick3D 1.15

import org.tal 1.0

ApplicationWindow {
    id: main
    width: 800
    height: 600
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
    property Window telepromtpwindow;
    
    Component.onCompleted: {
        oflags=flags;
        console.debug(Qt.application.screens.length)
        for(var i = 0;i < Qt.application.screens.length;i ++) {
            console.debug(i)
        }
        l3window=aws.createObject(main, { screen: Qt.application.screens[1]});
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
    
    Component {
        id: aws
        Window {
            id: secondaryWindow
            visible: true
            //visibility: Window.FullScreen
            title: ""
            minimumWidth: 800
            minimumHeight: 480
            //width: 1920
            //height: 1080
            modality: Qt.NonModal
            transientParent: null
            // flags: Qt.WA_AlwaysStackOnTop
            
            property var startTime;

            property alias promptPos: telepromt.contentY
            readonly property alias promptHeight: telepromt.contentHeight
            
            Component.onCompleted: {
                startTime=new Date()
            }
            
            onClosing: {
                close.accepted=false;
            }
            
            Rectangle {
                id: background
                anchors.fill: parent
                color: bgBlack.checked ? "black" : "green"
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
            
            ColumnLayout {
                anchors.fill: parent
                Text {
                    id: timeCurrent
                    Layout.fillWidth: true
                    color: "#ffffff"
                    text: "00:00:00"
                    styleColor: "#202020"
                    style: Text.Outline
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: secondaryWindow.height/5
                    visible: showTime.checked
                }
                Text {
                    id: timeCount
                    Layout.fillWidth: true
                    color: "#ffffff"
                    styleColor: "#202020"
                    style: Text.Outline
                    text: formatSeconds(ticker.seconds)
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: secondaryWindow.height/5
                    visible: showCounter.checked
                }
                Text {
                    id: timeCountdown
                    Layout.fillWidth: true
                    color: "#ffffff"
                    styleColor: "#202020"
                    style: Text.Outline
                    text: formatSeconds(ticker.countdown)
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: secondaryWindow.height/5
                    visible: showCountdown.checked
                }
                Text {
                    id: msgText
                    Layout.fillWidth: true
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
                TelepromptScroller {
                    id: telepromt
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: telepromtShow.checked
                    mirror: telepromtMirror.checked
                    flip: telepromtFlip.checked
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

            function telepromtStart() {
                telepromt.start()
            }
            function telepromtPause() {
                telepromt.pause()
            }
            function telepromtResume() {
                telepromt.resume()
            }
            function telepromtStop() {
                telepromt.stop()
            }
            function telepromtReset() {
                telepromt.reset()
            }
            function telepromtSetText(txt) {
                telepromt.text=txt;
            }
        }
    }
    
    menuBar: MenuBar {
        Menu {
            title: "File"
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
                text: "Quit"
                onClicked: Qt.quit()
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
                enabled: false
                onClicked: tsf.startSelector();
            }
            MenuItem {
                text: "Paste"
                enabled: textPrompter.canPaste
                onClicked: {
                    textPrompter.paste()
                    l3window.telepromtSetText(textPrompter.text)
                }
            }
            MenuItem {
                text: "Clear"
                onClicked: {
                    l3window.telepromtSetText("")
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
        }
    }

    TextSelector {
        id: tsftp
        filter: [ "*.txt" ]
        onFileSelected: {
            // l3Model.source=src
        }
    }

    TextSelector {
        id: tsf
        filter: [ "*.xml" ]
        onFileSelected: {
            l3Model.source=src
        }
    }

    XmlListModel {
        id: l3Model
        query: "/thirds/item"
        source: "persons.xml"

        XmlRole { name: "primary"; query: "primary/string()"; }
        XmlRole { name: "secondary"; query: "secondary/string()"; }

        onStatusChanged: {
            switch (status) {
            case XmlListModel.Ready:
                msg.text="T"
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

        ColumnLayout {
            id: itemMessage
            Layout.fillHeight: true
            Layout.fillWidth: true

            ScrollView {
                Layout.fillHeight: true
                Layout.fillWidth: true
                ScrollBar.vertical.policy: ScrollBar.AlwaysOn
                Layout.minimumHeight: gl.height/6
                Layout.maximumHeight: gl.height/4
                TextArea {
                    id: textMsg
                    placeholderText: "Write a message for the talent here"
                    selectByKeyboard: true
                    selectByMouse: true
                    textFormat: TextEdit.PlainText
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
            }
        }

        ColumnLayout {
            id: itemSelector
            Layout.fillWidth: true
            ListView {
                id: l3selector
                model: l3Model
                delegate: l3delegate
                clip: true
                Layout.fillHeight: true
                Layout.fillWidth: true
                highlight: Rectangle { color: "lightblue" }
                onCurrentIndexChanged: {
                    main.primary=l3Model.get(currentIndex).primary
                    main.secondary=l3Model.get(currentIndex).secondary
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
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignCenter
            Text {
                id: timeCurrent
                Layout.fillWidth: true
                text: "00:00:00"
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 48
            }
            RowLayout {
                Text {
                    id: timeCount
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: formatSeconds(ticker.seconds)
                    font.pixelSize: 32
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
                    id: showTime
                    Layout.alignment: Qt.AlignLeft
                    text: "Time"
                    checked: true
                }
                Switch {
                    id: showCounter
                    Layout.alignment: Qt.AlignLeft
                    text: "Counter"
                    checked: false
                }
                Switch {
                    id: showCountdown
                    Layout.alignment: Qt.AlignLeft
                    text: "Down"
                    checked: false
                }
                Switch {
                    id: showAnimation
                    Layout.alignment: Qt.AlignLeft
                    text: "Snow"
                    checked: false
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
                    text: "5min"
                    onClicked: ticker.setCountdownSeconds(5*60);
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
            Layout.fillHeight: true
            Layout.fillWidth: true

            ScrollView {
                Layout.fillHeight: false
                Layout.fillWidth: true
                Layout.maximumWidth: parent.width
                Layout.minimumHeight: cl2.height/6
                Layout.maximumHeight: cl2.height/4
                ScrollBar.vertical.policy: ScrollBar.AlwaysOn
                TextArea {
                    id: textPrompter
                    placeholderText: "Telepromt text here"
                    selectByKeyboard: true
                    selectByMouse: true
                    textFormat: TextEdit.PlainText
                }
            }

            RowLayout {
                Switch {
                    id: telepromtShow
                    Layout.alignment: Qt.AlignLeft
                    text: "Telepromt"
                    checked: false
                }
                Switch {
                    id: telepromtMirror
                    Layout.alignment: Qt.AlignLeft
                    text: "Mirror"
                    checked: false
                }

                Switch {
                    id: telepromtFlip
                    Layout.alignment: Qt.AlignLeft
                    text: "Flip"
                    checked: false
                }
            }

            RowLayout {
                Button {
                    text: "Update"
                    onClicked: {
                        l3window.telepromtSetText(textPrompter.text)
                    }
                }
                Button {
                    text: "Start"
                    onClicked: {
                        l3window.telepromtStart();
                    }
                }
                Button {
                    text: "Stop"
                    onClicked: {
                        l3window.telepromtStop();
                    }
                }
            }
            RowLayout {
                Button {
                    text: "Pause"
                    onClicked: {
                        l3window.telepromtPause();
                    }
                }
                Button {
                    text: "Resume"
                    onClicked: {
                        l3window.telepromtResume();
                    }
                }
                Button {
                    text: "Reset"
                    onClicked: {
                        l3window.telepromtStop();
                    }
                }
            }

            Slider {
                Layout.fillWidth: true
                id: telePromtPos
                from: 0
                to: l3window.promptHeight
                value: l3window.promptPos
                onValueChanged: {
                    if (pressed) {

                    }
                }
            }
        }
    }
}
