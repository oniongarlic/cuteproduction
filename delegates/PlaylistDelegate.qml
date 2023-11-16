import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ItemDelegate {
    id: playlistDelegate
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
            clip: true
            elide: Text.ElideLeft
            maximumLineCount: 1
        }
        Text {
            Layout.fillWidth: false
            text: formatSeconds(duration/1000)
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

