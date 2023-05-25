import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import Qt5Compat.GraphicalEffects

Window {
    id: maskWindow
    width: 1024
    height: 768
    visible: true
    title: qsTr("MaskWindow")

    property alias mask: mask.source
    
    onClosing: (close) => {
        close.accepted=false;
    }

    onScreenChanged: {
        console.debug("MaskWindow is now: "+screen.name)
        settings.setSettingsStr("windows/mainmask", screen.name)
    }

    Image {
        id: mask
        visible: false
        anchors.fill: parent
        asynchronous: true
        cache: false
        smooth: true
        mipmap: true
    }
    ShaderEffect {
        anchors.fill: parent
        blending: false
        property variant src: mask
        vertexShader: "/shaders/mask-vertex.qsb"
        fragmentShader: "/shaders/mask-fragment.qsb"
    }
}
