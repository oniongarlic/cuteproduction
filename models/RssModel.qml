import QtQuick 2.15
import QtQml.XmlListModel

XmlListModel {
    id: rssModel
    query: "/rss/channel/item"

    XmlListModelRole { name: "title"; elementName: "title/string()"; }
    XmlListModelRole { name: "description"; elementName: "description/string()"; }
    XmlListModelRole { name: "link"; elementName: "link/string()"; }

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
