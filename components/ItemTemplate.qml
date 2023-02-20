import QtQuick 2.15

Item {
    id: template
    width: parent.contentWidth
    height: parent.contentHeight
    
    property int alignX: Qt.AlignCenter
    property int alignY: Qt.AlignCenter
    
    property int hideAlign: Qt.AlignBottom
    
    property int customX: 0
    property int customY: 0

    property int margin: 32
    property int marginTop: 32
    property int marginBottom: 32

    property int marginLeft: 32
    property int marginRight: 32

    property Item positionParent: parent;

    onAlignXChanged: updatePositionX()
    onAlignYChanged: updatePositionY()

    property bool animate: true
    property int duration: 300
    property int behaviourDuration: animate ? duration : 0
    
    Behavior on x { NumberAnimation { duration: behaviourDuration; easing.type: Easing.InOutQuad } }
    Behavior on y { NumberAnimation { duration: behaviourDuration; easing.type: Easing.InOutQuad } }
    
    property bool showItem: true
    
    onShowItemChanged: {
        if (showItem)
            show()
        else
            hide()
    }
    
    Connections {
        target: positionParent
        function onWidthChanged() {
            updatePosition();
        }
        function onHeightChanged() {
            updatePosition()
        }
    }
    
    function show() {
        updatePosition();
    }
    
    function hide() {
        var p=positionParent;
        switch (hideAlign) {
        case Qt.AlignLeft:
            x=-(width+marginLeft)
            console.debug("AL:"+x)
            break;
        case Qt.AlignTop:
            y=-(height+marginTop)
            console.debug("AT:"+y)
            break;
        case Qt.AlignBottom:
            y=p.height+marginBottom
            console.debug("AB:"+y)
            break;
        case Qt.AlignRight:
            x=p.width+marginRight
            console.debug("AR:"+x)
            break;
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
            x=marginLeft;
            break;
        case Qt.AlignCenter:
            x=p.width/2-width/2
            break;
        case Qt.AlignRight:
            x=p.width-marginRight-width
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
            y=marginTop;
            break;
        case Qt.AlignCenter:
            y=p.height/2-height/2
            break;
        case Qt.AlignBottom:
            y=p.height-marginBottom-height
            break;
        }
    }

    function updatePosition() {
        updatePositionX();
        updatePositionY();
    }
}
