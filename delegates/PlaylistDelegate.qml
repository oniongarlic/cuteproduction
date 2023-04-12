import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.12

Component {
    id: playlistDelegate
    ItemDelegate {
        width: ListView.view.width
        height: c.height
        highlighted: ListView.isCurrentItem
        RowLayout {
            id: c
            spacing: 4
            width: parent.width
            Text {
                Layout.fillWidth: true
                text: source
                font.pointSize: 14
            }
        }
        onClicked: {
            ListView.currentIndex=index;
        }
        onDoubleClicked: {
            setMediaFile(index)
        }
    }
}
