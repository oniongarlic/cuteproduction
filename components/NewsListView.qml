import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: c
    property alias model: newsList.model
    property int currentIndex: newsList.currentIndex
    property alias delegate: newsList.delegate
    ColumnLayout {
        id: cl
        spacing: 4
        anchors.fill: parent

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
                enabled: model.count>0
                onClicked: {
                    newsList.model.clear();
                }
            }
            Button {
                text: "Shuffle"
                enabled: model.count>0
                onClicked: {
                    shuffle(model, model.count)
                }
            }
        }
        Label {
            text: "Items: "+newsList.count
        }
    }
}
