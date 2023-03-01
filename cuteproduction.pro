QT += qml quick quickcontrols2 multimedia mqtt

CONFIG += c++11

CONFIG += qzxing_qml qzxing_multimedia enable_decoder_1d_barcodes enable_decoder_qr_code enable_encoder_qr_code

unix {
    CONFIG +=link_pkgconfig
    message(PKGCONFIG)
}

link_pkgconfig {

packagesExist(libavformat) {
    PKGCONFIG += libavformat libavutil libavcodec
    message(libavformat)
}

packagesExist(QZXing) {
    PKGCONFIG += QZXing
    DEFINES += QZXING_QML ENABLE_ENCODER_GENERIC ENABLE_ENCODER_QR_CODE
    message(QZXing)
}

}

win32 {
    include(3rdparty/qzxing/src//QZXing-components.pri)
}

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
        src/main.cpp \
        src/filereader.cpp \
        src/html.cpp \
        src/settings.cpp \
        src/ticker.cpp \
        src/hyper.cpp \
        src/cutemqttclient.cpp

HEADERS += \
    src/filereader.h \
    src/html.h \
    src/settings.h \
    src/ticker.h \
    src/hyper.h \
    src/cutemqttclient.h

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

QMAKE_INFO_PLIST = Info.plist

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

