#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickView>
#include <QScreen>

#include "ticker.h"

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    
    qputenv("QSG_INFO", "1");
    
    QGuiApplication app(argc, argv);
    
    QList<QScreen *> screens = app.screens();
    qDebug("Application sees %d screens", screens.count());
    qDebug() << screens;
    
#if 1
    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    qmlRegisterType<Ticker>("org.tal", 1,0, "Ticker");
    
    QQmlContext* rootContext = engine.rootContext();
    engine.load(url);
#else
    QQuickView *view = new QQuickView;
    view->setSource(QUrl("qrc:/main.qml"));
    view->show();  
    
#endif
    
    return app.exec();
}
