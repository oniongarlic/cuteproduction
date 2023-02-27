import QtQuick 2.15

Image {
    id: qrcode
    width: 256
    height: 256
    sourceSize.width: 256
    sourceSize.height: 256
    cache: false   

    function setUrl(url) {
        qrcode.source="image://QZXing/encode/" + url
    }

    function clear() {
        qrcode.source=''
    }

    property ItemTemplate position: pos

    x: pos.x
    y: pos.y

    ItemTemplate {
        id: pos
        alignX: Qt.AlignRight
        alignY: Qt.AlignCenter
        width: parent.width
        height: parent.height
        positionParent: qrcode.parent
    }        

}
