import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.12

ColumnLayout {
    id: newsPanel
    spacing: 0
    visible: model.count>0 && tickerVisible && !needToHide

    property alias model: tickerList.model

    property int itemsVisible: 1
    property bool tickerVisible: false;

    property alias delay: tickerTimer.delay
    property alias counter: tickerTimer.ct

    property bool needToHide: false

    x: pos.x
    y: pos.y
    width: parent.width-64
    height: parent.height/1.5

    property ItemTemplate position: pos

    property alias showItem: pos.showItem

    ItemTemplate {
        id: pos
        alignX: Qt.AlignCenter
        alignY: Qt.AlignCenter
        marginTop: 32
        marginBottom: 32
        marginLeft: 32
        marginRight: 32
        width: parent.width
        height: parent.height
        positionParent: newsPanel.parent
        visible: false
    }   

    Timer {
        id: tickerTimer
        interval: 100
        running: newsPanel.visible && tickerList.count>1
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
            height: c.height+c.padding*2
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
                padding: 4
                font.capitalization: Font.AllUppercase
                font.weight: Font.Bold
                text: topic;
                anchors.verticalCenter: parent.verticalCenter
                verticalAlignment: Text.AlignVCenter
                maximumLineCount: 1
                elide: Text.ElideRight
                font.pixelSize: 44
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
        }
    }

    ListView {
        id: tickerList
        Layout.fillWidth: true
        Layout.margins: 0
        clip: true
        height: 58
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
        height: 16
        color: "#00855f"
        width: (parent.width/100)*tickerTimer.ct
        opacity: tickerMsg.opacity
        Behavior on width { NumberAnimation { } }
        Behavior on opacity { NumberAnimation { } }
    }

    Rectangle {
        id: tickerMsgContainer
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: "#ffffff"
        Behavior on opacity { NumberAnimation { duration: 500 } }
        Text {
            id: tickerMsg
            color: "#0062ae"
            padding: 8
            maximumLineCount: 8 // XXX Make adjustable
            width: parent.width
            height: parent.height
            elide: Text.ElideRight
            font.pixelSize: 42
            textFormat: Text.PlainText
            wrapMode: Text.Wrap
            text: ""
            Behavior on opacity { NumberAnimation { duration: 250 } }
        }
    }
}
