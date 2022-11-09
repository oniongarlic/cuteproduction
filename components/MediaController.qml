import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.12
import QtMultimedia 5.15

ColumnLayout {
    id: mediaSizing

    property CustomVideoOutput vo;

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
            text: "Reset Size"
            onClicked: {
                mpx.value=0;
                mpy.value=0;
                mpw.value=1;
                mph.value=1;
                mpa.value=0;
            }
        }
    }

    ButtonGroup {
        id: fillModeGroup
        onClicked: {
            vo.fillMode=button.fill;
        }
    }

    property rect size: Qt.rect(0, 0, 1, 1);
    property int angle: 0

    onSizeChanged: {        
        if (vo)
            vo.setMediaPosition(size);
    }

    onAngleChanged: {
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
        value: 0
        from: 0
        to: 360
        stepSize: 1
        wheelEnabled: true
        onValueChanged: mediaSizing.angle=value
    }
}
