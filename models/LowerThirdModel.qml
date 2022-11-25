import QtQuick 2.15
import QtQml.XmlListModel

XmlListModel {
    id: l3Model
    query: "/thirds/item"

    XmlListModelRole { name: "primary"; elementName: "primary"; }
    XmlListModelRole { name: "secondary"; elementName: "secondary"; }
    XmlListModelRole { name: "topic"; elementName: "topic"; }
    XmlListModelRole { name: "image"; elementName: "image"; }

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

