import QtQuick
import QtQml.XmlListModel

XmlListModel {
    id: rssModel
    query: "/rss/channel/item"

    XmlListModelRole { name: "title"; elementName: "title"; }
    XmlListModelRole { name: "description"; elementName: "description"; }
    XmlListModelRole { name: "link"; elementName: "link"; }

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

    function get(i) {
        var o = {}
        for (var j = 0; j < roles.length; ++j) {
            o[roles[j].name] = data(index(i,0), Qt.UserRole + j)
        }
        return o
    }
}
