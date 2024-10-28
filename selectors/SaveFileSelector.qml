import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs

Item {
    id: igs
    signal saveFile(string dst);

    function open() {
        filesDialog.open();
    }

    property alias filter: filesDialog.nameFilters

    FileDialog {
        id: filesDialog
        nameFilters: [ "*.txt" ]
        title: qsTr("Save file")
        fileMode: FileDialog.SaveFile
        currentFolder: StandardPaths.standardLocations(StandardPaths.DocumentsLocation)[0]
        onAccepted: {
            var f=""+selectedFile
            saveFile(f);
        }
    }
}
