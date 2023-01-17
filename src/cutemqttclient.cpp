#include "cutemqttclient.h"

#include <QMqttTopicFilter>
#include <QMqttSubscription>
#include <QJsonDocument>
#include <QJsonObject>

CuteMqttClient::CuteMqttClient(QObject *parent) : QMqttClient(parent)
{
    setClientId("ta-cuteproduction");
    setPort(1883);
}

int CuteMqttClient::publish(const QString &topic, const QString &message, int qos, bool retain)
{
    return QMqttClient::publish(QMqttTopicName(topic), message.toUtf8(), qos, retain);
}

CuteMqttSubscription* CuteMqttClient::subscribe(const QString &filter)
{
    QMqttSubscription *s=QMqttClient::subscribe(filter, 0);
    auto r=new CuteMqttSubscription(s, this);

    return r;
}

CuteMqttSubscription* CuteMqttClient::subscribeType(const QString &filter, CuteMqttSubscription::TopicType t)
{
    QMqttSubscription *s=QMqttClient::subscribe(filter, 0);
    qDebug() << "******* " << t;
    auto r=new CuteMqttSubscription(s, this, t);

    return r;
}

CuteMqttSubscription::CuteMqttSubscription(QMqttSubscription *s, CuteMqttClient *c)
    : m_sub(s)
    , m_client(c)
{
    connect(m_sub, &QMqttSubscription::messageReceived, this, &CuteMqttSubscription::handleMessage);
    m_type=TopicType::ByteArray;
    m_topic=m_sub->topic();
}

CuteMqttSubscription::CuteMqttSubscription(QMqttSubscription *s, CuteMqttClient *c, CuteMqttSubscription::TopicType t)
    : m_sub(s)
    , m_client(c)
{
    connect(m_sub, &QMqttSubscription::messageReceived, this, &CuteMqttSubscription::handleMessage);
    m_type=t;
    m_topic=m_sub->topic();
}

CuteMqttSubscription::~CuteMqttSubscription()
{
}

void CuteMqttSubscription::handleMessage(const QMqttMessage &qmsg)
{
    switch (m_type) {
    case TopicType::ByteArray:
        emit messageReceived(qmsg.payload());
        break;
    case TopicType::String:
        emit messageReceived(qmsg.payload());
        break;
    case TopicType::Integer:
        emit messageReceived(qmsg.payload().toInt()/(int)m_scale);
        break;
    case TopicType::Double:
        emit messageReceived(qmsg.payload().toDouble()/m_scale);
        m_scale=1.0;
        break;
    case TopicType::JsonObject:
        handleJsonMessage(qmsg);
        break;
    case TopicType::Bool:
        emit messageReceived(qmsg.payload().toInt()==0 ? false : true);
        break;
    default:
        qWarning() << "Unsupported data type" << m_type;
    break;
    }
}

void CuteMqttSubscription::handleJsonMessage(const QMqttMessage &qmsg)
{
    QJsonDocument json=QJsonDocument::fromJson(qmsg.payload());
    if (json.isNull() || json.isEmpty()) {
        qWarning() << "Invalid JSON from topic " << qmsg.topic();
        return;
    }    
    emit messageReceived(json.object().toVariantMap());
}

void CuteMqttSubscription::setScale(float scale)
{
    m_scale=scale;
}
