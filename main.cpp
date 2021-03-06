#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickView>
#include <QQuickStyle>
#include <QScreen>

#include "ticker.h"
#include "html.h"

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    
    qputenv("QSG_INFO", "1");

    qputenv("QML_XHR_ALLOW_FILE_READ", "1");
    
    QGuiApplication app(argc, argv);

    QCoreApplication::setOrganizationDomain("org.tal.cuteproduction");
    QCoreApplication::setOrganizationName("tal.org");
    QCoreApplication::setApplicationName("CuteProduction");
    QCoreApplication::setApplicationVersion("0.1");

    QQuickStyle::setStyle("Universal");
    
    QList<QScreen *> screens = app.screens();
    qDebug("Application sees %d screens", screens.count());
    qDebug() << screens;

    html htmltool;

    qmlRegisterType<Ticker>("org.tal", 1,0, "Ticker");

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);


    QQmlContext* rootContext = engine.rootContext();
    rootContext->setContextProperty("html", &htmltool);

    engine.load(url);

    
#ifdef Q_OS_WIN32
  SetThreadExecutionState(ES_CONTINUOUS | ES_DISPLAY_REQUIRED);
#endif
    
    return app.exec();
}
