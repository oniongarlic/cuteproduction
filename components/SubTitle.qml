import QtQuick 2.15

Rectangle {
    id: subContainer

    property ItemTemplate position: pos

    x: pos.x
    y: pos.y

    height: txtSub.height
    width: parent.width-64

    property alias text: txtSub.text

    visible: txtSub.text!=''

    color: "#90000000"

    onTextChanged: {
        pos.updatePosition()
    }

    ItemTemplate {
        id: pos
        alignX: Qt.AlignCenter
        alignY: Qt.AlignBottom
        width: parent.width
        height: txtSub.height
        positionParent: subContainer.parent
    }

    Text {
        id: txtSub
        color: "#ffffff"
        text: ""
        font.family: "Oxygen Mono"
        styleColor: "#202020"
        style: Text.Outline
        verticalAlignment: Text.AlignTop
        font.pixelSize: 32
        minimumPixelSize: 32
        wrapMode: Text.WordWrap
        fontSizeMode: Text.FixedSize
        textFormat: Text.PlainText
        x: 32
        y: 8
        width: parent.width-64
        height: contentHeight+16
    }
}



