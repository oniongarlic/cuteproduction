import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.12
import QtQml.XmlListModel
import QtQuick.Dialogs

import "../selectors"
import "../models"
import "../components"

Drawer {
    id: newsDrawer
    dragMargin: 0
    width: parent.width/1.5
    height: parent.height

    property ListModel tickerModel;
    property ListModel panelModel;

    function addItemToModel(model, item) {
        model.append(item)
        if (clearOnAdd.checked) {
            clearInput()
        }
    }

    function updateItemInList(list, item) {
        list.model.set(list.currentIndex, item)
    }

    function createItem() {
        const item={
            "topic": newsKeyword.text,
            "msg": newsBody.text,
            "url": newsLink.text}
        return item;
    }

    function clearInput() {
        newsKeyword.clear()
        newsBody.clear()
        newsLink.clear()
    }

    RssModel {
        id: rssModel
    }

    TextSelector {
        id: rssFile
        filter: [ "*.xml" ]
        onFileSelected: {
            rssModel.source=src
        }
    }

    URLSelector {
        id: rssUrl
        title: "RSS Feed URL"
        onAccepted: {
            rssModel.source=url
        }
    }

    Component {
        id: rssItemModel
        ItemDelegate {
            width: ListView.view.width
            height: c.height
            ColumnLayout {
                id: c
                spacing: 2
                Text {
                    text: title;
                    font.bold: true;
                    maximumLineCount: 1;
                    elide: Text.ElideRight
                }
                Text {
                    text: description;
                    wrapMode: Text.Wrap;
                    maximumLineCount: 2;
                    elide: Text.ElideRight
                }
                Text {
                    text: link;
                    maximumLineCount: 1;
                    elide: Text.ElideRight
                }
            }
            onClicked: {
                newsFeedList.currentIndex=index;
                newsKeyword.text=rssModel.get(index).title
                newsBody.text=html.stripTags(rssModel.get(index).description)
                newsLink.text=rssModel.get(index).link
            }
            onDoubleClicked: {                
                tickerModel.append(rssModel.getItem(index))
            }
        }
    }

    Component {
        id: newsEditorDelegate
        ItemDelegate {
            width: ListView.view.width
            height: c.height
            highlighted: ListView.isCurrentItem
            ColumnLayout {
                id: c
                width: parent.width
                Text {
                    text: topic;
                    font.bold: true;
                    maximumLineCount: 1;
                    elide: Text.ElideRight
                }
                Text {
                    text: msg;
                    wrapMode: Text.Wrap;
                }
            }
            onClicked: {                
                ListView.view.currentIndex=index;
            }
            onDoubleClicked: {
                newsKeyword.text=ListView.view.model.get(index).topic
                newsBody.text=ListView.view.model.get(index).msg
                newsLink.text=ListView.view.model.get(index).url
            }
        }
    }

    DropArea {
        id: newsDropArea
        anchors.fill: parent
        keys: ["text/plain"]
        onDropped: {
            console.debug(drop.hasText)
            console.debug(drop.hasHtml)
            console.debug(drop.hasUrls)
            console.debug(drop.hasColor)

            if (drop.hasUrls) {
                console.debug(drop.urls[0])
                rssModel.source=drop.urls[0]
                drop.acceptProposedAction()
            } else if (drop.hasText) {
                console.debug(drop.text)
                drop.acceptProposedAction()
            }
        }
    }
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 8
        TextField {
            id: newsKeyword
            Layout.fillWidth: true
            placeholderText: "Keyword"
            selectByMouse: true
        }
        ScrollView {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.minimumHeight: newsDrawer.height/7
            Layout.maximumHeight: newsDrawer.height/6
            ScrollBar.vertical.policy: ScrollBar.AlwaysOn
            background: Rectangle {
                border.color: "black"
                border.width: 1
            }
            TextArea {
                id: newsBody
                Layout.maximumHeight: newsKeyword.height*4
                placeholderText: "Body"
                selectByKeyboard: true
                selectByMouse: true
                wrapMode: TextEdit.WordWrap
            }
        }
        TextField {
            id: newsLink
            Layout.fillWidth: true
            placeholderText: "URL"
            inputMethodHints: Qt.ImhUrlCharactersOnly
            selectByMouse: true
        }
        RowLayout {
            spacing: 8
            Switch {
                id: clearOnAdd
                text: "Clear on add"
                checked: true
            }
            Button {
                text: "To Ticker"
                enabled: newsKeyword.length>0 && newsBody.length>0
                onClicked: {                    
                    addItemToModel(tickerModel, createItem())
                }
            }
            Button {
                text: "To Panel"
                enabled: newsKeyword.length>0 && newsBody.length>0
                onClicked: {                    
                    addItemToModel(panelModel, createItem())
                }
            }
            Button {
                text: "Update Ticker"
                enabled: newsKeyword.length>0 && newsBody.length>0 && newsTickerEditorList.currentIndex>-1
                onClicked: {                    
                    updateItemInList(newsTickerEditorList, createItem())
                }
            }
            Button {
                text: "Update Panel"
                enabled: newsKeyword.length>0 && newsBody.length>0 && newsPanelEditorList.currentIndex>-1
                onClicked: {                    
                    updateItemInList(newsPanelEditorList, createItem())
                }
            }
            Button {
                text: "Clear"
                enabled: newsKeyword.length>0 || newsBody.length>0
                onClicked: {
                    clearInput()
                }
            }            
        }
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: newsDrawer.height/4
            Layout.maximumHeight: newsDrawer.height/2
            NewsListView {
                id: newsTickerEditorList
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: tickerModel
                delegate: newsEditorDelegate
            }
            NewsListView {
                id: newsPanelEditorList
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: panelModel
                delegate: newsEditorDelegate                
            }
        }        
        ListView {
            id: newsFeedList
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: newsDrawer.height/4
            Layout.maximumHeight: newsDrawer.height/2
            model: rssModel
            delegate: rssItemModel
            clip: true
        }
        RowLayout {
            spacing: 8
            Button {
                text: "RSS File"
                onClicked: {
                    rssFile.startSelector()
                }
            }
            Button {
                text: "RSS URL"
                onClicked: {
                    rssUrl.open()
                }
            }
            Button {
                text: "Refresh"
                enabled: rssModel.source!=''
                onClicked: {
                    rssModel.reload()
                }
            }
            Button {
                text: "All to Ticker"
                enabled: rssModel.count>0
                onClicked: {
                    let i;
                    for (i=0;i<rssModel.count;i++) {                        
                        tickerModel.append(rssModel.getItem(i))
                    }
                }
            }
            Button {
                text: "All to Panel"
                enabled: rssModel.count>0
                onClicked: {
                    let i;
                    for (i=0;i<rssModel.count;i++) {                        
                        panelModel.append(rssModel.getItem(i))
                    }
                }
            }
            Label {
                text: "RSS: "+newsFeedList.count
            }
        }
    }
}
