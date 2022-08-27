import QtQuick 2.15

Item {
    id: template
    width: parent.contentWidth
    height: parent.contentHeight
    
    property int alignX: Qt.AlignCenter
    property int alignY: Qt.AlignCenter
    
    property int customX: 0
    property int customY: 0

    property int margin: 32

    property Item positionParent;

    onAlignXChanged: updatePositionX()
    onAlignYChanged: updatePositionY()
    
    Behavior on x { NumberAnimation { easing.type: Easing.InOutQuad} }
    Behavior on y { NumberAnimation { easing.type: Easing.InOutQuad} }
    
    Connections {
        target: positionParent
        function onWidthChanged() {
            updatePosition();
        }
        function onHeightChanged() {
            updatePosition()
        }
    }
    
    function setPosition(ax, ay) {
        alignX=ax;
        alignY=ay;
    }

    function updatePositionX() {
        var p=positionParent;
        switch (alignX) {
        case 0:
            x=customX;
            break;
        case Qt.AlignLeft:
            x=margin;
            break;
        case Qt.AlignCenter:
            x=p.width/2-width/2
            break;
        case Qt.AlignRight:
            x=p.width-margin-width
            break;
        }
    }
    
    function updatePositionY() {
        var p=positionParent;
        switch (alignY) {
        case 0:
            y=customY;
            break;
        case Qt.AlignTop:
            y=margin;
            break;
        case Qt.AlignCenter:
            y=p.height/2-height/2
            break;
        case Qt.AlignBottom:
            y=p.height-margin-height
            break;
        }
    }

    function updatePosition() {
        updatePositionX();
        updatePositionY();
    }
}
