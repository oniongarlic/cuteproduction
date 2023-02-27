import QtQuick 2.15
import QtQuick.XmlListModel 2.15

XmlListModel {
    id: rssModel
    query: "/rss/channel/item"

    XmlRole { name: "title"; query: "title/string()"; }
    XmlRole { name: "description"; query: "description/string()"; }
    XmlRole { name: "link"; query: "link/string()"; }

    function getItem(i) {
        const item={
                "topic": rssModel.get(i).title,
                "url": rssModel.get(i).link,
                "msg": html.stripTags(rssModel.get(i).description)
        }
        return item;
    }

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
