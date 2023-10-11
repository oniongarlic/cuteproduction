import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQml.XmlListModel
import QtQuick.Window
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
    property alias preview: previewSwitch.checked

    property VideoOutput previewVideo: previewOutput

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

        RowLayout {
            Layout.fillWidth: true

            ListView {
                id: mediaListView
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.minimumWidth: mediaDrawer.width/2
                clip: true
                delegate: PlaylistDelegate {

                }
                highlight: Rectangle { color: "#f0f0f0"; }
                ScrollIndicator.vertical: ScrollIndicator { }
                Rectangle {
                    border.color: "#ffffff"
                    border.width: 2
                    color: "transparent"
                    anchors.fill: parent
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop

                VideoOutput {
                    id: previewOutput
                    Layout.preferredWidth: 320
                    Layout.preferredHeight: 256
                    Layout.alignment: Qt.AlignTop
                    fillMode: VideoOutput.PreserveAspectFit

                    Rectangle {
                        border.color: "#ffffff"
                        border.width: 2
                        color: "transparent"
                        anchors.fill: parent
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Dial {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                        inputMode: Dial.Horizontal
                        from: 0.1
                        enabled: mp.seekable
                        stepSize: 0.1
                        snapMode: Dial.SnapAlways
                        to: 4
                        value: mp.playbackRate
                        onValueChanged: {
                            console.debug(value)
                            mp.playbackRate=value
                        }
                    }
                }
            }
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
                text: 1+playlist.currentIndex+" / "+playlist.count
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeft
            }
            Label {
                id: itemTime
                text: formatSeconds(mp.position/1000)+" / "+formatSeconds(mp.duration/1000)
            }
        }

        Slider {
            Layout.fillWidth: true
            from: 0
            enabled: mp.seekable
            to: mp.duration
            stepSize: 0.1
            onValueChanged: if (pressed || !mp.playing) mp.position=value
            value: mp.position
            wheelEnabled: true
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
            Switch {
                id: previewSwitch
                text: "Preview"
            }

        }

        RowLayout {
            spacing: 8
            Button {
                text: "Play"
                enabled: mp.playbackState!==MediaPlayer.PlayingState && mp.status!==MediaPlayer.NoMedia
                onClicked: {
                    if (mp.status===MediaPlayer.NoMedia) {
                        if (mediaListView.currentIndex>0)
                            setMediaFile(mediaListView.currentIndex)
                    } else {
                        mp.play();
                    }
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
                enabled: playlist.hasPrev
                onClicked: {
                    previousMediaFile();
                }
            }
            Button {
                text: "Next"
                enabled: playlist.hasNext
                onClicked: {
                    nextMediaFile();
                }
            }
        }
    }
}
