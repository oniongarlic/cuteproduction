import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.12

ColumnLayout {
    id: newsTicker
    spacing: 0
    visible: tickerModel.count>0 && tickerVisible && !needToHide

    property alias model: tickerList.model

    property int itemsVisible: 4
    property bool tickerVisible: false;

    property alias delay: tickerTimer.delay
    property alias counter: tickerTimer.ct

    property bool needToHide: false

    x: pos.x
    y: pos.y
    width: parent.width-64
    property ItemTemplate position: pos

    ItemTemplate {
        id: pos
        alignX: Qt.AlignLeft
        alignY: Qt.AlignBottom
        marginTop: 32
        marginBottom: newsTicker.height+32
        positionParent: newsTicker.parent
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

    Component {
        id: tickerDelegate
        ItemDelegate {
            width: tickerList.width/itemsVisible
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

    Component {
        id: tickerHighlight
        Rectangle {
            color: "#009bd8"
            Behavior on x {
                NumberAnimation { }
            }
        }
    }

    ListView {
        id: tickerList
        Layout.fillWidth: true
        Layout.margins: 0
        clip: true
        height: 48
        interactive: false
        orientation: ListView.Horizontal
        delegate: tickerDelegate
        // model: tickerModel
        highlightFollowsCurrentItem: true
        highlight: tickerHighlight
        highlightMoveDuration: 500
        snapMode: ListView.SnapToItem
        highlightRangeMode: ListView.StrictlyEnforceRange
        onCurrentIndexChanged: {
            console.debug("Tick: "+currentIndex)
            if (currentIndex<0)
                return;

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
