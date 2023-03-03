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
    width: (parent.width/widthAdjustment)-margin*2
    height: parent.height/heightAdjustment

    property int margin: 32

    property double widthAdjustment: 1
    property double heightAdjustment: 1.5

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
        animate: false
        // Hide it inside layout!
        visible: false
    }

    Timer {
        id: tickerTimer
        interval: 200
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
            width: tickerList.width
            highlighted: ListView.isCurrentItem
            height: c.height+c.padding*2
            background: Rectangle {
                color: highlighted ? "#ffffff" : "#b0b0b0"
                radius: 0
            }
            Text {
                id: c
                color: highlighted ? "#0062ae" : "#0062ae"
                width: parent.width
                padding: 4
                anchors.verticalCenter: parent.verticalCenter
                verticalAlignment: Text.AlignVCenter
                font.capitalization: Font.AllUppercase
                font.weight: Font.Bold
                font.pixelSize: 46
                text: topic;
                maximumLineCount: 1
                elide: Text.ElideRight
                textFormat: Text.PlainText
                wrapMode: Text.NoWrap
            }
        }
    }

    Component {
        id: tickerHighlight
        Rectangle {
            color: "#009bd8"
        }
    }

    RowLayout {
        id: rl
        Layout.fillWidth: true
        spacing: 0
        ListView {
            id: tickerList
            Layout.fillWidth: true
            Layout.margins: 0
            clip: true
            height: 68
            interactive: false
            orientation: ListView.Horizontal
            delegate: tickerDelegate
            snapMode: ListView.SnapToItem
            highlightFollowsCurrentItem: true
            highlight: tickerHighlight
            highlightMoveDuration: 500
            highlightRangeMode: ListView.StrictlyEnforceRange
            onCurrentIndexChanged: {
                console.debug("Tick: "+currentIndex)
                if (currentIndex<0)
                    return;

                tickerMsg.text=model.get(currentIndex).msg
                const url=model.get(currentIndex).url
                tickerMsg.opacity=1
                tickerMsgContainer.opacity=1
                qrcode.url=url
            }
        }
        Control {
            height: 68
            padding: 0
            background: Rectangle {
                color: "white"
                implicitHeight: 68
                implicitWidth: ctime.width
            }
            contentItem: Text {
                id: ctime
                color: "#0062ae"
                text: Qt.formatTime(main.date, "hh:mm:ss");
                font.bold: true
                font.pixelSize: 34
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                width: contentWidth+32
                height: contentHeight
                wrapMode: Text.NoWrap
            }
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
        RowLayout {
            anchors.fill: parent
            Text {
                Layout.fillWidth: true
                Layout.fillHeight: true
                id: tickerMsg
                color: "#0062ae"
                padding: 8
                //maximumLineCount: 8 // XXX Make adjustable
                elide: Text.ElideRight
                font.pixelSize: 42
                textFormat: Text.PlainText
                wrapMode: Text.Wrap
                text: ""
                lineHeight: 1.2
                minimumPixelSize: 36
                fontSizeMode: Text.Fit
                Behavior on opacity { NumberAnimation { duration: 250 } }
            }
            QrCode {
                Layout.alignment: Qt.AlignTop
                id: qrcode
                width: 256
                height: 256
                Layout.margins: 32
                visible: url!=''
            }
        }
    }
}
