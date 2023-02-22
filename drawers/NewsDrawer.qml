import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.12
import QtQuick.XmlListModel 2.15
import QtQuick.Dialogs 1.3

import "../selectors"
import "../models"

Drawer {
    id: newsDrawer
    dragMargin: 0
    width: parent.width/1.5
    height: parent.height

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
            }
            onClicked: {
                newsFeedList.currentIndex=index;
                newsKeyword.text=rssModel.get(index).title
                newsBody.text=html.stripTags(rssModel.get(index).description)
            }
            onDoubleClicked: {
                const news=rssModel.get(index)
                const item={ "topic": news.title, "msg": html.stripTags(news.description) }
                l3window.addNewsItem(item)
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
                console.debug(index)
                ListView.view.currentIndex=index;
            }
            onDoubleClicked: {
                newsKeyword.text=ListView.view.model.get(index).topic
                newsBody.text=ListView.view.model.get(index).msg
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
        RowLayout {
            spacing: 8
            Button {
                text: "Add"
                enabled: newsKeyword.length>0 && newsBody.length>0
                onClicked: {
                    const item={ "topic": newsKeyword.text, "msg": newsBody.text }
                    l3window.addNewsItem(item)
                    newsKeyword.clear()
                    newsBody.clear()
                }
            }
            Button {
                text: "Update"
                enabled: newsKeyword.length>0 && newsBody.length>0 && newsEditorList.currentIndex>-1
                onClicked: {
                    const item={ "topic": newsKeyword.text, "msg": newsBody.text }
                    newsEditorList.model.set(newsEditorList.currentIndex, item)
                    newsKeyword.clear()
                    newsBody.clear()
                }
            }
            Button {
                text: "Remove"
                enabled: newsEditorList.currentIndex>-1
                onClicked: {
                    newsEditorList.model.remove(newsEditorList.currentIndex)
                }
            }
            Button {
                text: "Remove all"
                onClicked: {
                    newsEditorList.model.clear();
                }
            }
            Button {
                text: "Clear"
                onClicked: {
                    newsKeyword.clear()
                    newsBody.clear()
                }
            }
            Button {
                text: "Close"
                onClicked: {
                    newsDrawer.close()
                }
            }
        }
        ListView {
            id: newsEditorList
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: l3window.newsTickerModel
            delegate: newsEditorDelegate
            clip: true
        }
        Label {
            text: "Items: "+newsEditorList.count
        }
        ListView {
            id: newsFeedList
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: rssModel
            delegate: rssItemModel
            clip: true
        }
        RowLayout {
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
                text: "Add all"
                enabled: rssModel.count>0
                onClicked: {
                    let i;
                    for (i=0;i<rssModel.count;i++) {
                        const item={ "topic": rssModel.get(i).title, "msg": html.stripTags(rssModel.get(i).description) }
                        l3window.addNewsItem(item)
                    }
                }
            }
            Label {
                text: "RSS: "+newsFeedList.count
            }
        }
    }
}
