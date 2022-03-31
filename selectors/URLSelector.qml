import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.12

Dialog {
    id: dialogURL
    title: "URL"
    standardButtons: StandardButton.Ok | StandardButton.Close

    property alias url: urlInput.text

    ColumnLayout {
        anchors.fill: parent

        TextInput {
            Layout.fillWidth: true
            id: urlInput

        }
    }

}
