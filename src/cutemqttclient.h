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
    enum TopicType {
        String=QMetaType::QString,
        ByteArray=QMetaType::QByteArray,
        Integer=QMetaType::Int,
        Double=QMetaType::Double,
        JsonObject=QMetaType::QJsonObject
    };
    Q_ENUM(TopicType)

    CuteMqttSubscription(QMqttSubscription *s, CuteMqttClient *c);
    CuteMqttSubscription(QMqttSubscription *s, CuteMqttClient *c, CuteMqttSubscription::TopicType t);
    ~CuteMqttSubscription();

    Q_INVOKABLE void setType(CuteMqttSubscription::TopicType t) { qDebug() << ":*" << t ; m_type=t; };

Q_SIGNALS:
    void topicChanged(QString);
    void messageReceived(const QVariant &msg);
    void messageMapReceived(const QVariantMap &msg);

public slots:
    void handleMessage(const QMqttMessage &qmsg);
    void handleJsonMessage(const QMqttMessage &qmsg);
    void setScale(float scale);

private:
    Q_DISABLE_COPY(CuteMqttSubscription)

    QMqttSubscription *m_sub;
    QMqttTopicFilter m_topic;
    TopicType m_type;
    CuteMqttClient *m_client;

    float m_scale;
};

Q_DECLARE_METATYPE(CuteMqttSubscription::TopicType)

class CuteMqttClient : public QMqttClient
{
    Q_OBJECT
public:
    CuteMqttClient(QObject *parent = nullptr);

    Q_INVOKABLE int publish(const QString &topic, const QString &message, int qos=1, bool retain=false);
    Q_INVOKABLE CuteMqttSubscription* subscribe(const QString &filter);
    CuteMqttSubscription* subscribeType(const QString &filter, CuteMqttSubscription::TopicType t);
private:
    Q_DISABLE_COPY(CuteMqttClient)
};

#endif // CUTEMQTTCLIENT_H
