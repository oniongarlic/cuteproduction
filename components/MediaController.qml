import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.12
import QtMultimedia 5.15

ColumnLayout {
    id: mediaSizing

    property CustomVideoOutput vo;    

    property var savedSize: [];
    property var savedAngles: [];

    Component.onCompleted: {
        savedSize[0]=Qt.rect(0, 0, 0.90, 0.90)
        savedSize[1]=Qt.rect(0, 0, 1, 1)
        savedSize[2]=Qt.rect(0.027, 0.107, 0.7, 0.7)
        savedAngles[0]=15;
        savedAngles[1]=25;
        savedAngles[2]=35;
    }

    function loadPosition(i) {
        mpx.value=mediaSizing.savedSize[i].x;
        mpy.value=mediaSizing.savedSize[i].y;
        mpw.value=mediaSizing.savedSize[i].width;
        mph.value=mediaSizing.savedSize[i].height;
        mpa.value=mediaSizing.savedAngles[i];
    }

    function savePosition(i) {
        mediaSizing.savedSize[i].x=mediaSizing.size.x;
        mediaSizing.savedSize[i].y=mediaSizing.size.y;
        mediaSizing.savedSize[i].width=mediaSizing.size.width;
        mediaSizing.savedSize[i].height=mediaSizing.size.height;
        mediaSizing.savedAngles[i]=mediaSizing.angle
    }

    RowLayout {
        Layout.fillWidth: true
        RadioButton {
            text: "Fill"
            readonly property int fill: VideoOutput.PreserveAspectFit
            checked: true
            ButtonGroup.group: fillModeGroup
        }
        RadioButton {
            text: "Crop"
            readonly property int fill: VideoOutput.PreserveAspectCrop
            ButtonGroup.group: fillModeGroup
        }
        Button {
            text: "F"
            onClicked: {
                mpx.value=0;
                mpy.value=0;
                mpw.value=1;
                mph.value=1;
                mpa.value=0;
                angle=0
            }
        }
        Button {
            text: "C"
            onClicked: {
                mpx.value=0.25;
                mpy.value=0.25;
                mpw.value=0.5;
                mph.value=0.5;
                mpa.value=0;
                angle=0
            }
        }
        Button {
            text: "0"
            onClicked: {
                mpx.value=0.5;
                mpy.value=0.5;
                mpw.value=0;
                mph.value=0;
                mpa.value=0;
            }
        }
        Button {
            text: "A"
            onClicked: {
                loadPosition(0)
            }
        }
        Button {
            text: "B"
            onClicked: {
                loadPosition(1)
            }
        }
        Button {
            text: "C"
            onClicked: {
                loadPosition(2)
            }
        }
    }

    RowLayout {
        Button {
            text: "Set A"
            onClicked: {
                savePosition(0)
            }
        }
        Button {
            text: "Set B"
            onClicked: {
                savePosition(1)
            }
        }
        Button {
            text: "Set C"
            onClicked: {
                savePosition(2)
            }
        }
    }

    onSavedSizeChanged: console.debug(savedSize)

    ButtonGroup {
        id: fillModeGroup
        onClicked: {
            vo.fillMode=button.fill;
        }
    }

    property rect size: Qt.rect(0, 0, 1, 1);
    property int angle: 0

    onSizeChanged: {
        console.debug(size)
        if (vo)
            vo.setMediaPosition(size);
    }

    onAngleChanged: {
        console.debug(angle)
        if (vo)
            vo.setMediaAngle(angle)
    }

    Slider {
        id: mpx
        Layout.fillWidth: true
        from: -1
        value: 0
        to: 1
        stepSize: 0.001
        wheelEnabled: true
        onValueChanged: mediaSizing.size.x=value;
    }
    Slider {
        id: mpy
        Layout.fillWidth: true
        from: -1
        value: 0
        to: 1
        stepSize: 0.001
        wheelEnabled: true
        onValueChanged: mediaSizing.size.y=value
    }
    Slider {
        id: mph
        Layout.fillWidth: true
        value: 1
        stepSize: 0.001
        wheelEnabled: true
        onValueChanged: mediaSizing.size.height=value
    }
    Slider {
        id: mpw
        Layout.fillWidth: true
        value: 1
        stepSize: 0.001
        wheelEnabled: true
        onValueChanged: mediaSizing.size.width=value
    }
    Slider {
        id: mpa
        Layout.fillWidth: true
        from: -360
        value: 0
        to: 360
        stepSize: 1
        wheelEnabled: true
        onValueChanged: mediaSizing.angle=value
    }
}
