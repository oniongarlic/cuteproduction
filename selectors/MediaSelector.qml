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

    FileDialog {
        id: filesDialog
        title: qsTr("Select media file(s)")
        currentFolder: StandardPaths.standardLocations(StandardPaths.MoviesLocation)[0]
        nameFilters: [ "*.mp4", "*.mov", "*.mp3", "*.avi", "*.jpg" ]        
        fileMode: FileDialog.OpenFile
        onAccepted: {
            fileSelected(selectedFile);
        }
    }
}
