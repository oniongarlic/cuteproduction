import QtQuick 2.15

Text {
    id: txtTemplate
    color: "#ffffff"
    text: ""
    font.family: "Oxygen Mono"
    font.bold: true
    styleColor: "#202020"
    style: Text.Outline
    horizontalAlignment: Text.AlignHCenter
    minimumPixelSize: 24
    font.pixelSize: 142
    fontSizeMode: Text.HorizontalFit
    textFormat: Text.PlainText
    
    width: contentWidth
    height: contentHeight
    
    property int alignX: Qt.AlignCenter
    property int alignY: Qt.AlignCenter
    
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
    
    onAlignXChanged: updatePosition()
    onAlignYChanged: updatePosition()
    
    function setPosition(ax, ay) {
        alignX=ax;
        alignY=ay;
    }
    
    function updatePosition() {
        var m=32; // margin
        var p=parent;
        // X
        switch (alignX) {
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
