import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Dialogs 1.3
import QtQuick.Layouts 1.15

Item {
    id: igs

    signal fileSelected(string src);
    signal filesSelected(var src);

    function startSelector() {
        filesDialog.open();
    }

    property alias filter: filesDialog.nameFilters
    property alias selectExisting: filesDialog.selectExisting
    property alias selectFolder: filesDialog.selectFolder
    property alias selectMultiple: filesDialog.selectMultiple
    property alias shortcuts: filesDialog.shortcuts

    FileDialog {
        id: filesDialog
        folder: shortcuts.documents
        nameFilters: [ "*.txt" ]
        title: qsTr("Select text file")
        selectExisting: true
        selectFolder: false
        selectMultiple: false
        onAccepted: {
            // XXX: Need to convert to string, otherwise sucka
            if (fileUrl!="") {
                var f=""+fileUrl
                fileSelected(f);
            } else {
                console.debug(fileUrls)
                filesSelected(fileUrls)
            }
        }
    }
}
