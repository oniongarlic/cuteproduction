import QtQuick 2.15
import QtQuick.XmlListModel 2.15

XmlListModel {
    id: rssModel
    query: "/rss/channel/item"

    XmlRole { name: "title"; query: "title/string()"; }
    XmlRole { name: "description"; query: "description/string()"; }

    onStatusChanged: {
        switch (status) {
        case XmlListModel.Ready:

            break;
        case XmlListModel.Error:
            console.debug(errorString())
            break;
        }
    }
}
