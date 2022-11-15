import QtQuick 2.15
import QtQuick.XmlListModel 2.15

XmlListModel {
    id: l3Model
    query: "/thirds/item"

    XmlRole { name: "primary"; query: "primary/string()"; }
    XmlRole { name: "secondary"; query: "secondary/string()"; }
    XmlRole { name: "topic"; query: "topic/string()"; }
    XmlRole { name: "image"; query: "image/string()"; }

    signal loaded()

    onStatusChanged: {
        switch (status) {
        case XmlListModel.Ready:
            loaded()
            break;
        case XmlListModel.Error:
            console.debug(errorString())
            break;
        }
    }

    function copyToListModel(tmodel) {
        tmodel.clear();
        for (let i=0;i<count;i++) {
            tmodel.append(get(i))
        }
    }

}

