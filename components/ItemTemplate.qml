import QtQuick 2.15

Item {
    id: txtTemplate
    width: contentWidth
    height: contentHeight
    
    property int alignX: Qt.AlignCenter
    property int alignY: Qt.AlignCenter
    
    property int customX: 0
    property int customY: 0
    
    Behavior on x { NumberAnimation { easing.type: Easing.InOutQuad} }
    Behavior on y { NumberAnimation { easing.type: Easing.InOutQuad} }
    
    Connections {
        target: txtTemplate.parent
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
    
    function updatePosition() {
        var m=32; // margin
        var p=parent;
        // X
        switch (alignX) {
        case 0:
            x=customX;
            break;
        case Qt.AlignLeft:
            x=m;
            break;
        case Qt.AlignCenter:
            x=p.width/2-width/2
            break;
        case Qt.AlignRight:
            x=p.width-32-width
            break;
        }
        
        // Y
        switch (alignY) {
        case 0:
            y=customY;
            break;
        case Qt.AlignTop:
            y=m;
            break;
        case Qt.AlignCenter:
            y=height/2+p.height/2
            break;
        case Qt.AlignBottom:
            y=p.height-m-height
            break;
        }
    }
}
