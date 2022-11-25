QT += quick quickcontrols2 multimedia mqtt

CONFIG += c++11

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

# QMediaPlaylist
SOURCES += 3rdparty/qmediaplaylist/qmediaplaylist.cpp 3rdparty/qmediaplaylist/playlistmodel.cpp 3rdparty/qmediaplaylist/qplaylistfileparser.cpp
HEADERS += 3rdparty/qmediaplaylist/playlistmodel.h 3rdparty/qmediaplaylist/qmediaplaylist.h 3rdparty/qmediaplaylist/qmediaplaylist_p.h 3rdparty/qmediaplaylist/qplaylistfileparser_p.h
INCLUDEPATH += 3rdparty/qmediaplaylist/

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

