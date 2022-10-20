#include "hyper.h"

CuteHyper::CuteHyper(QObject *parent) :
    QObject(parent),
    m_connections(0),
    m_tc(0),    
    m_clips(0),
    m_clip_len(0),
    m_loop(0)
{
    m_playlist = new QMediaPlaylist(this);
    m_server = new QTcpServer(this);
    if (!m_server->listen(QHostAddress::AnyIPv4, 9993)) {
        qWarning() << "Unable to start the server: " << m_server->errorString();
    } else {
        qDebug() << m_server->serverAddress() << m_server->serverPort();
    }
    connect(m_server, SIGNAL(newConnection()), this, SLOT(newConnection()));
}

void CuteHyper::setStatus(QString status)
{
    m_status=status;
    emit statusChanged();
}

void CuteHyper::setTimecode(int tc)
{
    m_tc=tc;
}

void CuteHyper::setDuration(int du)
{
    m_clip_len=du;
}

void CuteHyper::setClips(int clips)
{
    m_clips=clips;
}

void CuteHyper::writeResponse(QTcpSocket *con, QByteArray key, QByteArray val)
{
    con->write(key);
    con->write(": ");
    con->write(val);
    con->write("\r\n");
}

void CuteHyper::writeResponse(QTcpSocket *con, QString key, QString val)
{
    writeResponse(con, key.toLocal8Bit(), val.toLocal8Bit());
}

void CuteHyper::writeResponse(QTcpSocket *con, QString key, bool val)
{
    writeResponse(con, key, val ? "true" : "false");
}

void CuteHyper::writeResponse(QTcpSocket *con, QString key, int val)
{
    writeResponse(con, key.toLocal8Bit(), QByteArray::number(val));
}

void CuteHyper::writeAck(QTcpSocket *con, QByteArray code, QByteArray val)
{
    con->write(code);
    con->write(" ");
    con->write(val);
    con->write("\r\n");
}

void CuteHyper::onReadyRead()
{
    QTcpSocket *con = qobject_cast<QTcpSocket*>(sender());

    while (con->canReadLine()) {
        QByteArray ba = con->readLine();
        qDebug() << ba;

        auto cmdp= ba.split(' ');
        QByteArray cmd=cmdp.at(0);
        qDebug() << cmd << cmdp;

        if (cmd.startsWith("quit")) {
            writeAck(con, "200", "ok");
            disconnectRemoteAccess();
            m_server->close();
            return;
        } else if (cmd.startsWith("ping")) {
            qDebug() << "ping";

            writeAck(con, "200", "ok");
        } else if (cmd.startsWith("play")) {
            qDebug() << "play";

            emit play();
            writeAck(con, "200", "ok");
        } else if (cmd.startsWith("record")) {
            qDebug() << "record";

            emit record();
            writeAck(con, "200", "ok");
        } else if (cmd.startsWith("stop")) {
            qDebug() << "stop";

            emit stop();
            writeAck(con, "200", "ok");
        } else if (cmd.startsWith("notify:")) {
            qDebug() << "notify response";

            writeAck(con, "209", "notify:");
            writeResponse(con, "transport", true);
            writeResponse(con, "slot", true);
            writeResponse(con, "remote", true);
            writeResponse(con, "configuration", false);
            con->write("\r\n");

        } else if (cmd.startsWith("transport info")) {
            qDebug() << "transport response";

            QTime tc(0,0,0);
            tc=tc.addSecs(m_tc);
            QString stc=tc.toString("00:hh:mm:ss");

            qDebug() << "tc" << stc << m_status;

            writeAck(con, "208", "transport info:");
            writeResponse(con, "status", m_status);
            writeResponse(con, "speed", m_speed);

            con->write("slot id: 1\r\n");
            writeResponse(con, "display timecode: ", stc);
            writeResponse(con, "timecode: ", stc);
            if (m_clips>0)
                writeResponse(con, "clip id", 1);
            else
                writeResponse(con, "clip id", "none");
            writeResponse(con, "single clip", true);
            writeResponse(con, "slot", true);
            con->write("video format: 1080p30\r\n");
            writeResponse(con, "loop", false);
            con->write("\r\n");

        } else if (cmd.startsWith("clips count")) {
            qDebug() << "clips count response";
            con->write("214 clips count:\r\n");            
            writeResponse(con, "clip count", m_playlist->mediaCount());
            con->write("\r\n");

        } else if (cmd.startsWith("clips get")) {
            QTime tc(0,0,0);
            tc=tc.addSecs(m_clip_len);
            QString stc=tc.toString("00:hh:mm:ss");

            qDebug() << "clips get response" << m_clip_len << stc;

            writeAck(con, "205", "clips info:");
            writeResponse(con, "clip count", m_playlist->mediaCount());
            if (m_playlist->mediaCount()>0) {
                con->write("1: media.mov H.264High 1080p30 00:00:00:00 ");
                con->write(stc.toLocal8Bit());
                con->write("\r\n");
            }
            con->write("\r\n");

        } else if (cmd.startsWith("disk list")) {
            qDebug() << "disk response";

            QTime tc(0,0,0);
            tc=tc.addSecs(m_clip_len);
            QString stc=tc.toString("00:hh:mm:ss");

            writeAck(con, "206", "disk list:");
            con->write("slot id: 1\r\n");
            con->write("1: media.mov H.264High 1080p30 00:00:00:00 ");
            con->write(stc.toLocal8Bit());
            con->write("\r\n");
            con->write("\r\n");

        } else if (cmd.startsWith("slot info: slot id: 1")) {
            qDebug() << "slot 1 response";
            con->write("202 slot info:\r\n");
            con->write("slot id: 1\r\n");
            con->write("status: mounted\r\n");
            con->write("volume name: CUTEHYPER\r\n");
            con->write("recording time: 36000\r\n");
            con->write("video format: 1080p30\r\n");
            con->write("\r\n");

        } else if (cmd.startsWith("slot info: slot id: 2")) {
            qDebug() << "slot 2 response";
            con->write("202 slot info:\r\n");
            con->write("slot id: 2\r\n");
            con->write("status: empty\r\n");
            con->write("volume name: \r\n");
            con->write("recording time: 0\r\n");
            con->write("video format: 1080p30\r\n");
            con->write("\r\n");

        } else if (cmd.startsWith("slot info")) {
            qDebug() << "slot 0 response";
            con->write("202 slot info:\r\n");
            con->write("slot id: 1\r\n");
            con->write("status: mounted\r\n");
            con->write("volume name: CUTEHYPER\r\n");
            con->write("recording time: 36000\r\n");
            con->write("video format: 1080p30\r\n");
            con->write("\r\n");

        } else if (cmd.startsWith("goto")) {
            writeAck(con, "200", "ok");

        } else if (cmd.startsWith("help")) {
            writeAck(con, "200", "ok");

        } else if (cmd.startsWith("remote")) {
            qDebug() << "remote response";

            writeAck(con, "210", "remote info:");
            writeResponse(con, "enabled", true);
            writeResponse(con, "override", false);
            con->write("\r\n");

        } else if (cmd.startsWith("configuration")) {
            writeAck(con, "211", "configuration:");
            con->write("audio input: embedded\r\n");
            con->write("video input: HDMI\r\n");
            con->write("\r\n");
        } else {            
            writeAck(con, "103", "unsupported");
        }
    }
}
void CuteHyper::disconnectRemoteAccess() {
    QTcpSocket *con = qobject_cast<QTcpSocket*>(sender());

    qDebug() << "Remote disconnected" << con->peerAddress();

    con->deleteLater();

    m_connections--;
}

void CuteHyper::newConnection() {
    if (m_connections<10) {
        QTcpSocket *tmp = m_server->nextPendingConnection();

        qDebug() << "Remote connection accepted" << m_connections << tmp->peerAddress();

        tmp->write("500 connection info:\r\n");
        tmp->write("protocol version: 1.11\r\n");
        tmp->write("model: HyperDeck Studio Mini\r\n");
        tmp->write("unique id: 123456789\r\n");
        tmp->write("\r\n");

        connect(tmp, SIGNAL(disconnected()), this, SLOT(disconnectRemoteAccess()));
        connect(tmp, SIGNAL(readyRead()), this, SLOT(onReadyRead()));

        m_connections++;
    } else {
        qDebug("Max remote connections already exists, deny.");
        QTcpSocket *tmp = m_server->nextPendingConnection();
        connect(tmp, SIGNAL(disconnected()), tmp, SLOT(deleteLater()));
        tmp->write("120 connection rejected\n");
        tmp->disconnectFromHost();
    }
}
