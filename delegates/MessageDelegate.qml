import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.12

ItemDelegate {
    width: parent.width
    height: c.height+32
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
            maximumLineCount: 1
            Layout.fillWidth: true
            Layout.margins: 8
            elide: Text.ElideRight
            font.pointSize: 14
            textFormat: Text.PlainText
            wrapMode: Text.NoWrap
        }
        Text {
            Layout.fillWidth: true
            Layout.margins: 8
            text: secondary;
            textFormat: Text.PlainText
            font.pointSize: 12
            elide: Text.ElideRight
            maximumLineCount: 6
            wrapMode: Text.Wrap
        }
    }
}
