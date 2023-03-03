import QtQuick 2.15

Rectangle {
    id: qrcodeWrapper
    width: 256+32
    height: 256+32
    color: "white"
    
    property string url
    property ItemTemplate position: pos

    property bool show: false

    visible: show && url!=''

    x: pos.x
    y: pos.y

    ItemTemplate {
        id: pos
        alignX: Qt.AlignRight
        alignY: Qt.AlignCenter
        width: parent.width
        height: parent.height
        positionParent: qrcodeWrapper.parent
    }    
    
    Image {
        id: qrcode
        anchors.fill: parent
        anchors.margins: 16
        sourceSize.width: 256
        sourceSize.height: 256
        fillMode: Image.PreserveAspectFit
        cache: false
        source: url!='' ? "image://QZXing/encode/" + url : ''
    }
}


