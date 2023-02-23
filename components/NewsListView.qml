import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.12

ColumnLayout {

    property alias model: newsList.model
    property int currentIndex: newsList.currentIndex
    property alias delegate: newsList.delegate

    ListView {
        id: newsList
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true
    }
    RowLayout {
        spacing: 8
        Layout.fillWidth: true
        Button {
            text: "Remove"
            enabled: newsList.currentIndex>-1
            onClicked: {
                newsList.model.remove(newsList.currentIndex)
            }
        }
        Button {
            text: "Remove all"
            onClicked: {
                newsList.model.clear();
            }
        }
    }
    Label {
        text: "Items: "+newsList.count
    }
}
