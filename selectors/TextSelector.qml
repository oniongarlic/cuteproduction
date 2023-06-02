import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts

Item {
    id: igs

    signal fileSelected(string src);
    signal filesSelected(var src);

    function startSelector() {
        filesDialog.open();
    }

    property alias filter: filesDialog.nameFilters
    // property alias selectExisting: filesDialog.selectExisting
    // property alias selectFolder: filesDialog.selectFolder
    // property alias selectMultiple: filesDialog.selectMultiple
    // property alias shortcuts: filesDialog.shortcuts

    FileDialog {
        id: filesDialog
        nameFilters: [ "*.txt" ]
        title: qsTr("Select text file")
        currentFolder: StandardPaths.standardLocations(StandardPaths.DocumentsLocation)[0]
        onAccepted: {
            // XXX: Need to convert to string, otherwise sucka
            if (selectedFile!="") {
                var f=""+selectedFile
                fileSelected(f);
            } else {
                console.debug(selectedFiles)
                filesSelected(selectedFiles)
            }
        }
    }
}
