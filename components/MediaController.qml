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
        savedSize[0]=Qt.rect(0.05, 0.05, 0.84, 0.84)
        savedSize[1]=Qt.rect(0, 0, 0.805, 0.805)
        savedSize[2]=Qt.rect(0.027, 0.107, 0.7, 0.7)
        savedAngles[0]=8;
        savedAngles[1]=12;
        savedAngles[2]=17;
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
        Switch {
            id: posAB
            text: "AB"
            onCheckedChanged: {
                vo.animationDuration=checked ? 2000 : 250
            }
        }
    }

    Timer {
        id: positionAnimator
        running: posAB.checked
        repeat: true
        interval: 4000
        triggeredOnStart: true

        property int curPos: 0

        onTriggered: {
            loadPosition(curPos)
            curPos=!curPos
        }
    }

    RowLayout {
        Layout.fillWidth: true
        Switch {
            id: mediaVisible
            text: "Visible"
            checked: true
            onCheckedChanged: {
                vo.visible=checked
            }
        }
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
        SpinBox {
            id: animationSpeed
            from: 0
            to: 300
            stepSize: 1
            value: vo.animationDuration/100
            onValueChanged: {
                vo.animationDuration=value*100
            }
        }
        Switch {
            id: mediaBorder
            text: "Border"
            checked: false
            onCheckedChanged: {
                vo.borderRect.visible=checked
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

    SliderSpinboxRow {
        id: mpx
        text: "X"
        onValueChanged: {
            vo.animate=!pressed; mediaSizing.size.x=value; vo.animate=true;
        }
    }
    SliderSpinboxRow {
        id: mpy
        text: "Y"
        onValueChanged: {
            vo.animate=!pressed; mediaSizing.size.y=value; vo.animate=true;
        }
    }
    SliderSpinboxRow {
        id: mpw
        from: 0
        to: 1
        text: "W"
        onValueChanged: {
            vo.animate=!pressed; mediaSizing.size.width=value; vo.animate=true;
        }
    }
    SliderSpinboxRow {
        id: mph
        from: 0
        to: 1
        text: "H"
        onValueChanged: {
            vo.animate=!pressed; mediaSizing.size.height=value; vo.animate=true;
        }
    }
    SliderSpinboxRow {
        id: mpa
        from: -360
        stepSize: 1
        to: 360
        spinScale: 1
        text: "A"
        onValueChanged: {
            vo.animate=!pressed; mediaSizing.angle=value; vo.animate=true;
        }
    }
}
