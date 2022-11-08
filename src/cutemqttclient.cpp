#include "cutemqttclient.h"

#include <QMqttTopicFilter>
#include <QMqttSubscription>

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

CuteMqttSubscription* CuteMqttClient::subscribeType(const QString &filter, QMetaType::Type t)
{
    QMqttSubscription *s=QMqttClient::subscribe(filter, 0);
    auto r=new CuteMqttSubscription(s, this, t);

    return r;
}

CuteMqttSubscription::CuteMqttSubscription(QMqttSubscription *s, CuteMqttClient *c)
    : m_sub(s)
    , m_client(c)
{
    connect(m_sub, &QMqttSubscription::messageReceived, this, &CuteMqttSubscription::handleMessage);
    m_type=QMetaType::QByteArray;
    m_topic=m_sub->topic();
}

CuteMqttSubscription::CuteMqttSubscription(QMqttSubscription *s, CuteMqttClient *c, QMetaType::Type t)
    : m_sub(s)
    , m_client(c)
{
    switch (t) {
    case QMetaType::QByteArray:
        connect(m_sub, &QMqttSubscription::messageReceived, this, &CuteMqttSubscription::handleMessage);
        break;
    case QMetaType::QString:
        connect(m_sub, &QMqttSubscription::messageReceived, this, &CuteMqttSubscription::handleStringMessage);
        break;
    case QMetaType::Int:
        connect(m_sub, &QMqttSubscription::messageReceived, this, &CuteMqttSubscription::handleNumericMessage);
        break;
    case QMetaType::Float:
    case QMetaType::Double:
        connect(m_sub, &QMqttSubscription::messageReceived, this, &CuteMqttSubscription::handleNumericMessage);
        m_scale=1.0;
        break;
    default:
        qWarning("Unsupported data type");
    break;
    }

    m_type=t;
    m_topic=m_sub->topic();
}

CuteMqttSubscription::~CuteMqttSubscription()
{
}

void CuteMqttSubscription::handleMessage(const QMqttMessage &qmsg)
{
    emit messageReceived(qmsg.payload());
}

void CuteMqttSubscription::handleStringMessage(const QMqttMessage &qmsg)
{
    emit messageStringReceived(qmsg.payload());
}

void CuteMqttSubscription::handleNumericMessage(const QMqttMessage &qmsg)
{
    emit messageNumericReceived(qmsg.payload().toFloat()/m_scale);
}

void CuteMqttSubscription::handleIntegerMessage(const QMqttMessage &qmsg)
{
    emit messageNumericReceived(qmsg.payload().toInt()/(int)m_scale);
}

void CuteMqttSubscription::setScale(float scale)
{
    m_scale=scale;
}
