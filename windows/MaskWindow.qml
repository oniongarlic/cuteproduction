import QtQuick
import QtQuick.Window
import QtQuick.Controls

Window {
    id: maskWindow
    width: 1024
    height: 768
    x: screen.virtualX
    y: screen.virtualY
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
