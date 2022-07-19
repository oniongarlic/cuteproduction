import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.12

ItemDelegate {
    width: ListView.view.width
    height: c.height
    background: Rectangle {
        color: "#009bd8"
        radius: 8
        border.color: "#0062ae"
    }

    ColumnLayout {
        id: c
        spacing: 4
        width: parent.width
        Text {
            text: primary;
            color: "white"
            font.bold: true
            maximumLineCount: 1
            elide: Text.ElideRight
            font.pixelSize: 28
            textFormat: Text.PlainText
            wrapMode: Text.NoWrap
            visible: text.length>0
            Layout.fillWidth: true
            Layout.margins: 8
        }
        Text {
            text: secondary;
            color: "white"
            textFormat: Text.PlainText
            font.pixelSize: 24
            elide: Text.ElideRight
            maximumLineCount: 6
            wrapMode: Text.Wrap
            Layout.fillWidth: true
            Layout.margins: 8
        }
    }
}
