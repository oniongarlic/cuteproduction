import QtQuick

Text {
    id: txtTemplate
    color: "#ffffff"
    text: ""
    font.family: "Oxygen Mono"
    font.bold: true
    styleColor: "#202020"
    style: Text.Outline
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignTop
    font.pixelSize: 96
    minimumPixelSize: 32
    fontSizeMode: Text.HorizontalFit
    textFormat: Text.PlainText
    width: parent.width/4
    height: contentHeight
    wrapMode: Text.NoWrap

    property ItemTemplate position: pos

    x: pos.x
    y: pos.y

    ItemTemplate {
        id: pos
        alignX: Qt.AlignCenter
        alignY: Qt.AlignCenter
        width: parent.width
        positionParent: txtTemplate.parent                
    }
}

