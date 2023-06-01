#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickView>
#include <QQuickStyle>
#include <QFontDatabase>
#include <QScreen>

#ifdef QZXING_QML
#include <QZXing.h>
#endif

#include "ticker.h"
#include "html.h"
#include "filereader.h"
#include "settings.h"
#include "hyper.h"
#include "cutemqttclient.h"

#include "playlistmodel.h"

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    
    qputenv("QSG_INFO", "1");    
    
    QGuiApplication app(argc, argv);

    QCoreApplication::setOrganizationDomain("org.tal.cuteproduction");
    QCoreApplication::setOrganizationName("tal.org");
    QCoreApplication::setApplicationName("CuteProduction");
    QCoreApplication::setApplicationVersion("0.1");

    QStringList fonts;
    fonts << ":/data/fonts/OxygenMono-Regular.ttf" << ":/data/fonts/OpenSans-Regular.ttf" << ":/data/fonts/OpenSans-Bold.ttf";

    foreach(const QString &font, fonts) {
        const int fid = QFontDatabase::addApplicationFont(font);
        qDebug() << "Font loaded: " << fid << QFontDatabase::applicationFontFamilies(fid);
    }

    QQuickStyle::setStyle("Universal");
    
    QList<QScreen *> screens = app.screens();
    qDebug("Application sees %d screens", screens.count());
    qDebug() << screens;

    html htmltool;
    Settings settings;

    qmlRegisterType<Ticker>("org.tal", 1,0, "Ticker");
    qmlRegisterType<FileReader>("org.tal", 1,0, "FileReader");

    qmlRegisterType<CuteHyper>("org.tal.cutehyper", 1, 0, "HyperServer");
    qmlRegisterType<CuteMqttClient>("org.tal.mqtt", 1, 0, "MqttClient");
    qRegisterMetaType<CuteMqttSubscription::TopicType>("TopicType");
    qmlRegisterUncreatableType<CuteMqttSubscription>("org.tal.mqtt", 1, 0, "MqttSubscription", QLatin1String("MQTT subscriptions are read-only"));        

    qmlRegisterType<QMediaPlaylist>("org.tal.trdparty", 1, 0, "Playlist");

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));

#ifdef QZXING_QML
    QZXing::registerQMLTypes();
    QZXing::registerQMLImageProvider(engine);
#endif

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    QQmlContext* rootContext = engine.rootContext();
    rootContext->setContextProperty("html", &htmltool);
    rootContext->setContextProperty("settings", &settings);

    engine.load(url);
    
#ifdef Q_OS_WIN32
  SetThreadExecutionState(ES_CONTINUOUS | ES_DISPLAY_REQUIRED);
#endif
    
    return app.exec();
}
