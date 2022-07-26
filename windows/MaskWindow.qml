import QtQuick 2.15
import QtQuick.Window 2.15
import QtGraphicalEffects 1.15

Window {
    id: maskWindow
    width: 1024
    height: 768
    visible: true
    title: qsTr("MaskWindow")

    property alias mask: mask.source
    
    onClosing: {
        close.accepted=false;
    }

    Image {
        id: mask
        visible: false
        anchors.fill: parent
        asynchronous: true
        cache: false
        smooth: false
        mipmap: true
    }
    ShaderEffect {
        anchors.fill: parent
        property variant src: mask
        vertexShader: "
            uniform highp mat4 qt_Matrix;
            attribute highp vec4 qt_Vertex;
            attribute highp vec2 qt_MultiTexCoord0;
            varying highp vec2 coord;
            void main() {
                coord = qt_MultiTexCoord0;
                gl_Position = qt_Matrix * qt_Vertex;
            }"
        fragmentShader: "
            varying highp vec2 coord;
            uniform sampler2D src;
            uniform lowp float qt_Opacity;
            void main() {
                lowp vec4 tex = texture2D(src, coord);
                gl_FragColor = vec4(tex.a, tex.a, tex.a, 1);
            }"
    }
}
