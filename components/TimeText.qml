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
    font.pixelSize: 128
    fontSizeMode: Text.HorizontalFit
    textFormat: Text.PlainText
    width: contentWidth
    height: contentHeight

    property ItemTemplate position: pos

    x: pos.x
    y: pos.y

    ItemTemplate {
        id: pos
        alignX: Qt.AlignCenter
        alignY: Qt.AlignCenter
        positionParent: txtTemplate.parent
    }
}

