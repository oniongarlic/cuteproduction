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
        nameFilters: [ "Video (*.mp4 *.mov *.avi)", "Audio (*.mp3 *.ogg)", "Image (*.jpg *.png)" ]
        fileMode: FileDialog.OpenFiles
        onAccepted: {
            if (selectedFiles.length==1)
                fileSelected(selectedFile);
            else
                filesSelected(selectedFiles)
        }
    }
}
