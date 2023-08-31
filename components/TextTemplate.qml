import QtQuick

Text {
    id: txtTemplate
    color: "#ffffff"
    text: ""
    font.family: "Oxygen Mono"
    font.bold: true
    styleColor: "#202020"
    style: Text.Outline
    horizontalAlignment: Text.AlignLeft
    verticalAlignment: Text.AlignTop
    font.pixelSize: 96
    minimumPixelSize: 32
    fontSizeMode: Text.HorizontalFit
    textFormat: Text.PlainText
    width: parent.width
    height: contentHeight
}
