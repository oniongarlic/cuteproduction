import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Qt5Compat.GraphicalEffects

Rectangle {
    id: l3
    color: "white"
    border.color: "#0062ae"
    border.width: 4
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

    property bool useOpacity: false

    property bool showImage: true

    visible: false
    width: fullWidth ? parent.width-margin*2 : (parent.width/2.0)-margin*2
    //height: cl.height+8
    height: (parent.height/3)*0.5
    x: xpos
    y: ypos

    radius: 6

    layer.enabled: useOpacity
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
    
    readonly property bool isActive: defaultAnimation.running
    
    property alias mainTitle: txtPrimary.text
    property alias secondaryTitle: txtSecondary.text
    property alias topic: txtTopic.text
    property alias image: person.source

    function setDetails(m, s, t='', i='') {
        mainTitle=m;
        secondaryTitle=s;
        topic=t;
        image=i;
    }
    
    property alias displayTime: displayTimer.duration

    onHeightChanged: resetLocation()
    onWidthChanged: resetLocation()
    onL3BottomMarginChanged: resetLocation()

    function resetLocation() {
        x=getXpos(parent.width, width, alignHorizontal);
        y=getYpos(parent.height, height, l3BottomMargin, alignVertical);
    }

    function show() {
        defaultAnimation.stop()
        visible=false;
        resetLocation();
        defaultAnimation.start()
    }

    function hide() {
        resetLocation()
        visible=false;
    }

    property Animation defaultAnimation: l3animation

    Item {
        id: _dummy
    }
    
    SequentialAnimation {
        id: l3animation
        ScriptAction {
            script: {
                resetLocation();
                l3.visible=true;
            }
        }
        ParallelAnimation {
            NumberAnimation {
                target: l3
                property: "x"
                easing.type: Easing.InOutCubic;
                duration: 1200
                from: getXpos(l3.parent.width, l3.width, alignHorizontal)
                to: alignHorizontal==Qt.AlignLeft ? margin : (fullWidth ? margin : l3.parent.width/2+margin)
            }
            NumberAnimation {
                target: useOpacity ? l3 : _dummy;
                property: "opacity"
                from: 0
                to: 1
                easing.type: Easing.InOutCubic;
                duration: 1000;
            }
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
            NumberAnimation {
                target: useOpacity ? l3 : _dummy;
                property: "opacity"
                from: 1
                to: 0
                easing.type: Easing.InOutCubic;
                duration: 800;
            }
        }
        ScriptAction {
            script: {
                resetLocation();
                l3.visible=false;
            }
        }
    }
    
    Rectangle {
        id: topicBox
        color: "#0062ae"
        visible: txtTopic.text=='' ? false : true
        anchors.bottom: l3.top
        width: l3.width/2
        height: l3.height/3
        Text {
            id: txtTopic
            anchors.fill: parent
            color: "#f0f0f0"
            text: ""
            font.family: "Helvetica"
            font.capitalization: Font.AllUppercase
            font.bold: true
            font.pixelSize: 24
            minimumPixelSize: 18
            fontSizeMode: Text.Fit
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }
    }
    
    RowLayout {
        id: rl
        anchors.fill: parent
        spacing: 0
        Rectangle {
            id: box
            color: "#0062ae"
            Layout.preferredWidth: l3.height
            Layout.preferredHeight: l3.height
            
            Image {
                id: person
                visible: showImage && source!='' && status==Image.Ready
                anchors.fill: parent
                anchors.margins: 4
                smooth: true
                fillMode: Image.PreserveAspectCrop
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

            // Layout.minimumWidth: l3.width
            //Layout.preferredWidth: wc
            Layout.maximumWidth: l3.width-box.width

            readonly property int wc: Math.max(txtPrimary.contentWidth, txtSecondary.contentWidth)
            readonly property int wt: Math.max(txtPrimary.width, txtSecondary.width)

            Text {
                id: txtPrimary
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignRight
                color: "#0062ae"
                text: ""
                font.family: "Helvetica"
                font.bold: true
                font.pixelSize: 42
                minimumPixelSize: 32
                fontSizeMode: Text.HorizontalFit
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignRight
                elide: Text.ElideRight
                textFormat: Text.PlainText
                maximumLineCount: 1
            }
            Text {
                id: txtSecondary
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignRight
                color: "#0062ae"
                text: ""
                font.family: "Helvetica"
                font.pixelSize: 32
                minimumPixelSize: 22
                fontSizeMode: Text.HorizontalFit
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignRight
                elide: Text.ElideRight
                textFormat: Text.PlainText
                maximumLineCount: 1
            }
        }
    }
}
