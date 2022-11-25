import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Dialogs
import QtQuick.Layouts 1.12

Dialog {
    id: dialogURL
    title: "Input URL"
    width: 400
    standardButtons: StandardButton.Ok | StandardButton.Close

    property alias url: urlInput.text

    RowLayout {
        anchors.fill: parent
        spacing: 8
        Label {
            text: "URL"
        }
        TextField {
            Layout.fillWidth: true
            id: urlInput
            focus: true
            selectByMouse: true
            placeholderText: "https://"
        }
        Button {
            text: "Paste"
            enabled: urlInput.canPaste
            onClicked: {
                urlInput.paste()
            }
        }
    }    
}
