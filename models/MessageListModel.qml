import QtQuick

ListModel {
    id: msgModel
    property bool autoClean: true;
    property int autoCleanCount: 5
    onCountChanged: {
        if (count>autoCleanCount)
            remove(5, 1)
    }
}
