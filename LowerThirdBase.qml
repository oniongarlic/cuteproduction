import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.15

Rectangle {
    id: l3
    color: "white"
    border.color: "#0062ae"
    border.width: 2    
    gradient: Gradient {
        orientation: Gradient.Horizontal
        GradientStop {
            position: 0.00;
            color: "#e0e0e0";
        }
        GradientStop {
            position: 0.90;
            color: "#ffffff";
        }
        GradientStop {
            position: 1.00;
            color: "#ffffff";
        }
    }

    property bool fullWidth: true    
    property int margin: 32
    
    property int alignHorizontal: Qt.AlignLeft
    property int alignVertical: Qt.AlignBottom

    visible: x>-width
    //radius: 8
    width: fullWidth ? parent.width-margin*2 : (parent.width/2.0)-margin
    height: cl.height+8
    x: xpos
    y: ypos

    layer.enabled: false
    layer.effect: Glow {
        anchors.fill: l3
        radius: 8
        samples: 16
        color: "black"
        source: l3
        transparentBorder: true
    }

    readonly property int xpos: getXpos(parent.width, width, alignHorizontal) // -width-margin
    
    function getXpos(pw, w, ah) {
        switch (ah) {
        case Qt.AlignLeft:
            return -w-margin
        case Qt.AlignRight:
            return pw+margin
        }
    }
    
    readonly property int ypos: getYpos(parent.height, height, l3BottomMargin, alignVertical)
    
    function getYpos(ph,h,m,av) {
        switch (av) {
        case Qt.AlignBottom:
            return ph-h-m
        case Qt.AlignCenter:
            return ph/2-h/2
        case Qt.AlignTop:
            return m
        }
    }
    
    property int l3BottomMargin: margin+8
    
    readonly property bool isActive: l3animation.running
    
    property alias mainTitle: txtPrimary.text
    property alias secondaryTitle: txtSecondary.text
    property alias topic: txtTopic.text
    property alias image: person.source
    
    property alias displayTime: displayTimer.duration

    onHeightChanged: resetLocation()
    onWidthChanged: resetLocation()
    onL3BottomMarginChanged: resetLocation()

    function resetLocation() {
        x=getXpos(parent.width, width, alignHorizontal);
        y=getYpos(parent.height, height, l3BottomMargin, alignVertical);
    }
    
    SequentialAnimation {
        id: l3animation
        ScriptAction {
            script: resetLocation();
        }
        ParallelAnimation {
            NumberAnimation {
                target: l3
                property: "x"
                easing.type: Easing.InOutCubic;
                duration: 1200
                from: getXpos(l3.parent.width, width, alignHorizontal)
                to: alignHorizontal==Qt.AlignLeft ? margin : width+margin
            }
//            NumberAnimation {
//                target: l3
//                property: "opacity"
//                from: 0
//                to: 1
//                easing.type: Easing.InOutCubic;
//                duration: 1000
//            }
        }
        PauseAnimation {
            id: displayTimer
            duration: 2000
        }
        ParallelAnimation {
            NumberAnimation {
                target: l3
                property: "y"
                easing.type: Easing.InOutCubic;
                duration: 800
                to: l3.parent.height+16
                from: ypos
            }
//            NumberAnimation {
//                target: l3
//                property: "opacity"
//                from: 1
//                to: 0
//                easing.type: Easing.InOutCubic;
//                duration: 800
//            }
        }
        ScriptAction {
            script: resetLocation();
        }
    }
    
    RowLayout {
        id: rl
        anchors.fill: parent
        spacing: 0
        Rectangle {
            id: box
            height: parent.height
            width: height
            color: "#1e7eec"

            Image {
                id: person
                source: "person.png"
                visible: false
                width: box.width
                height: width
                fillMode: Image.PreserveAspectFit
                anchors.bottom: parent.bottom
            }

            Text {
                id: txtTopic
                anchors.fill: parent
                color: "#f0f0f0"
                text: ""
                font.family: "Helvetica"
                font.bold: false
                font.pixelSize: 24
                minimumPixelSize: 18
                fontSizeMode: Text.Fit
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }
        }

        ColumnLayout {
            id: cl
            spacing: 8
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 4
            Layout.rightMargin: 16
            Layout.leftMargin: 16

            Layout.minimumWidth: wc+32
            Layout.preferredWidth: wc+64
            Layout.maximumWidth: rl.width

            readonly property int wc: Math.max(txtPrimary.contentWidth, txtSecondary.contentWidth)

            Text {
                id: txtPrimary
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignRight
                color: "#0062ae"
                text: ""
                font.family: "Helvetica"
                font.bold: true
                font.pixelSize: 42
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignRight
            }
            Text {
                id: txtSecondary
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignRight
                color: "#0062ae"
                text: ""
                font.family: "Helvetica"
                font.pixelSize: 32
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignRight
            }
        }
    }
    
    function show() {
        l3animation.stop()
        resetLocation();
        l3animation.start()
    }
    function hide() {
        resetLocation()
    }
}
