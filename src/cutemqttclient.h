#ifndef CUTEMQTTCLIENT_H
#define CUTEMQTTCLIENT_H

#include <QObject>
#include <QMetaType>
#include <QtMqtt/QMqttClient>

class CuteMqttClient;

class CuteMqttSubscription : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QMqttTopicFilter topic MEMBER m_topic NOTIFY topicChanged)
public:
    CuteMqttSubscription(QMqttSubscription *s, CuteMqttClient *c);
    CuteMqttSubscription(QMqttSubscription *s, CuteMqttClient *c, QMetaType::Type t);
    ~CuteMqttSubscription();

Q_SIGNALS:
    void topicChanged(QString);

    void messageReceived(const QByteArray &msg);
    void messageStringReceived(const QString &msg);
    void messageIntegerReceived(int number);
    void messageNumericReceived(double number);

public slots:
    void handleMessage(const QMqttMessage &qmsg);
    void handleStringMessage(const QMqttMessage &qmsg);
    void handleNumericMessage(const QMqttMessage &qmsg);
    void handleIntegerMessage(const QMqttMessage &qmsg);

    void setScale(float scale);

private:
    Q_DISABLE_COPY(CuteMqttSubscription)

    QMqttSubscription *m_sub;
    QMqttTopicFilter m_topic;
    QMetaType::Type m_type;
    CuteMqttClient *m_client;

    float m_scale;
};

class CuteMqttClient : public QMqttClient
{
    Q_OBJECT
public:
    CuteMqttClient(QObject *parent = nullptr);

    Q_INVOKABLE int publish(const QString &topic, const QString &message, int qos=1, bool retain=false);
    Q_INVOKABLE CuteMqttSubscription* subscribe(const QString &filter);
    Q_INVOKABLE CuteMqttSubscription* subscribeType(const QString &filter, QMetaType::Type t);
private:
    Q_DISABLE_COPY(CuteMqttClient)
};

#endif // CUTEMQTTCLIENT_H
