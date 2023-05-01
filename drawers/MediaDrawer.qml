import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.12
import QtQml.XmlListModel
import QtQuick.Window 2.15
import QtQuick.Dialogs

import QtMultimedia

import "../selectors"
import "../models"
import "../components"
import "../delegates"
import "../windows"

Drawer {
    id: mediaDrawer
    dragMargin: 0
    width: parent.width/1.25
    height: parent.height

    property alias playlist: mediaListView.model

    property alias muted: checkMuted.checked
    property alias volume: volumeDial.value
    property alias loop: checkLoop.checked

    DropArea {
        id: mediaDropArea
        anchors.fill: parent
        // XXX: huh?
        //keys: ["video/quicktime", "video/mp4", "audio/mpeg", "audio/mp3", "audio/flac", "application/ogg"]
        onDropped: {
            if (drop.hasUrls) {
                console.debug(drop.urls[0])
                mediaListView.model.addItems(drop.urls);
                drop.acceptProposedAction()
            }
        }
    }

    PlaylistDelegate {
        id: playlistDelegate
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 8
        ListView {
            id: mediaListView
            Layout.fillHeight: true
            Layout.fillWidth: true
            clip: true
            delegate: playlistDelegate
            highlight: Rectangle { color: "#f0f0f0"; }
            ScrollIndicator.vertical: ScrollIndicator { }
        }

        RowLayout {
            spacing: 8
            Button {
                text: "Add"
                onClicked: {
                    ms.startSelector();
                }
            }
            Button {
                text: "Add URL"
                onClicked: {
                    usd.open()
                }
            }
            Button {
                text: "Remove"
                enabled: mediaListView.currentIndex>-1
                onClicked: {
                    mediaListView.model.remove(mediaListView.currentIndex)
                }
            }
            Button {
                text: "Clear"
                onClicked: {
                    mediaListView.model.clear()
                }
            }
            Button {
                text: "Close"
                onClicked: {
                    mediaDrawer.close()
                }
            }
        }

        RowLayout {
            spacing: 8
            Label {
                id: conMsg
                text: mp.errorString
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeft
            }
            Label {
                id: bufMsg
                text: mp.bufferProgress
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeft
            }
            Label {
                id: itemsMsg
                text: 1+plist.currentIndex+" / "+plist.count
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeft
            }
            Label {
                id: itemTime
                text: formatSeconds(mp.position/1000)+" / "+formatSeconds(mp.duration/1000)
            }
        }

        RowLayout {
            spacing: 8
            Slider {
                id: volumeDial
                from: 0
                to: 100
                value: 100
                stepSize: 1
                wheelEnabled: true

                NumberAnimation {
                    id: volumeFadeIn
                    //from: 0
                    to: 100
                    target: volumeDial
                    property: "value"
                    duration: 500
                    easing.type: Easing.InOutQuad
                }
                NumberAnimation {
                    id: volumeFadeOut
                    //from: 100
                    to: 0
                    target: volumeDial
                    property: "value"
                    duration: 500
                    easing.type: Easing.InOutQuad
                }
            }

            CheckBox {
                id: checkMuted
                text: "Mute"
                checked: mp.muted
            }

            Button {
                text: "Fade In"
                enabled: !volumeFadeIn.running
                onClicked: volumeFadeIn.start()
            }
            Button {
                text: "Fade Out"
                enabled: !volumeFadeOut.running
                onClicked: volumeFadeOut.start()
            }
            CheckBox {
                id: checkLoop
                text: "Loop"
                checked: mp.loops!=1
            }
        }

        RowLayout {
            spacing: 8
            Button {
                text: "Play"
                enabled: mp.playbackState!=MediaPlayer.PlayingState && mp.status!=MediaPlayer.NoMedia
                onClicked: {
                    mp.play();
                }
            }
            Button {
                text: "Pause"
                enabled: mp.playbackState==MediaPlayer.PlayingState
                onClicked: {
                    mp.pause()
                }
            }
            Button {
                text: "Stop"
                enabled: mp.playbackState==MediaPlayer.PlayingState
                onClicked: {
                    mp.stop();
                }
            }
            Button {
                text: "Previous"
                onClicked: {
                    previousMediaFile();
                }
            }
            Button {
                text: "Next"
                onClicked: {
                    nextMediaFile();
                }
            }
        }
    }
}
