import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.12

RowLayout {
    Layout.fillWidth: true
    spacing: 2

    property alias from: mp.from
    property alias to: mp.to
    property alias stepSize: mp.stepSize
    property alias value: mp.value
    property alias pressed: mp.pressed

    property int spinScale: 1000

    property alias text: label.text

    Label {
        id: label
    }
    Slider {
        id: mp
        Layout.fillWidth: true
        from: -1
        value: 0
        to: 1
        stepSize: 0.001
        wheelEnabled: true
    }
    SpinBox {
        Layout.fillWidth: false
        wheelEnabled: true
        editable: true
        value: mp.value*spinScale
        from: mp.from*spinScale
        to: mp.to*spinScale
        stepSize: 1
        onValueModified: {
            mp.value=value/spinScale
        }
    }
}
