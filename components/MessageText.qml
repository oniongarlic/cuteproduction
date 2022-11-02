import QtQuick 2.15

Text {
    id: txtTemplate
    color: "#ffffff"
    text: ""
    styleColor: "#202020"
    style: Text.Outline
    fontSizeMode: Text.HorizontalFit
    textFormat: Text.PlainText
    height: contentHeight
    minimumPixelSize: 48
    font.pixelSize: 72
    wrapMode: Text.Wrap
    maximumLineCount: 6
    horizontalAlignment: Text.AlignJustify
    verticalAlignment: Text.AlignTop
    width: parent.width/1.5

    property ItemTemplate position: pos

    x: pos.x
    y: pos.y

    ItemTemplate {
        id: pos
        alignX: Qt.AlignCenter
        alignY: Qt.AlignCenter
        width: parent.width
        height: parent.height
        positionParent: txtTemplate.parent
    }
}
