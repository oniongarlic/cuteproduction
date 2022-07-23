import QtQuick 2.15

Text {
    id: timeTxt
    anchors.horizontalCenter: parent.horizontalCenter
    width: parent.width
    color: "#ffffff"
    text: ""
    font.family: "FreeSans"
    font.bold: true
    styleColor: "#202020"
    style: Text.Outline
    horizontalAlignment: Text.AlignHCenter
    minimumPixelSize: 24
    font.pixelSize: 142
    fontSizeMode: Text.HorizontalFit
    textFormat: Text.PlainText
}
