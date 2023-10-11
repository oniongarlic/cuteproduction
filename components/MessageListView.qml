import QtQuick

ListView {
    id: msgList
    anchors.margins: 16
    spacing: 8
    interactive: false
    // clip: true
    verticalLayoutDirection: ListView.BottomToTop

    property int xpos: -width-32

    add: Transition {
        NumberAnimation {
            easing.type: Easing.InOutQuad
            properties: "x";
            from: xpos
            duration: 1200
        }
    }
    populate: Transition {
        NumberAnimation {
            easing.type: Easing.InOutBack
            properties: "x";
            from: xpos;
            duration: 800
        }
    }
    move: Transition {
        NumberAnimation {
            easing.type: Easing.InOutCubic
            properties: "x,y";
            duration: 800
        }
    }
    displaced: Transition {
        NumberAnimation {
            easing.type: Easing.InOutCubic
            properties: "x,y";
            duration: 800
        }
    }
    remove: Transition {
        NumberAnimation {
            easing.type: Easing.OutQuad
            properties: "x";
            to: xpos;
            duration: 800
        }
    }
}
