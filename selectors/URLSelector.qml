import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    id: dialogURL
    title: "Input URL"
    width: 400
    modal: true
    standardButtons: Dialog.Ok | Dialog.Close

    property alias url: urlInput.text
    property alias label: label.text

    RowLayout {
        anchors.fill: parent
        spacing: 8
        Label {
            id: label
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
