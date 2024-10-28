#ifndef FILEREADER_H
#define FILEREADER_H

#include <QObject>
#include <QFile>
#include <QUrl>
#include <QVariantMap>
#include <QVariantList>

#ifdef FFMPEG
extern "C" {
#include <libavformat/avformat.h>
#include <libavutil/dict.h>
}
#endif

class FileReader : public QObject
{
    Q_OBJECT
public:
    explicit FileReader(QObject *parent = nullptr);

    Q_INVOKABLE QByteArray data();
    Q_INVOKABLE bool read(QUrl file);
    Q_INVOKABLE bool write(QUrl file, QByteArray data);
    Q_INVOKABLE void clear();

    Q_INVOKABLE QVariantMap getMetaData(const QString file);
#ifdef FFMPEG
    Q_ENUM(AVMediaType);
#endif

signals:

private:
    QByteArray m_data;

};

#endif // FILEREADER_H
