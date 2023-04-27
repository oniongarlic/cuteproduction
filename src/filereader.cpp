#include "filereader.h"

#include <QDebug>

FileReader::FileReader(QObject *parent)
    : QObject{parent}
{

}

QVariantMap FileReader::getMetaData(const QString file)
{
    QVariantMap meta;
#ifdef FFMPEG
    AVFormatContext *fmt_ctx = NULL;
    AVDictionaryEntry *tag = NULL;
    int ret;

    if ((ret = avformat_open_input(&fmt_ctx, file.toLocal8Bit().data(), NULL, NULL)))
        return meta;

    qDebug() << "format" << fmt_ctx->iformat->name;
    qDebug() << "duration" << fmt_ctx->duration;
    qDebug() << "bitrate" << fmt_ctx->bit_rate;
    qDebug() << "streams" << fmt_ctx->nb_streams;

    meta.insert("bitrate", qint64(fmt_ctx->bit_rate));
    meta.insert("format", fmt_ctx->iformat->name);
    meta.insert("streams", fmt_ctx->nb_streams);

    while ((tag = av_dict_get(fmt_ctx->metadata, "", tag, AV_DICT_IGNORE_SUFFIX))) {
        qDebug() << tag->key << tag->value;
        meta.insert(tag->key, QString(tag->value));
    }

    if (avformat_find_stream_info(fmt_ctx,  NULL) < 0) {
        qDebug() << "avformat_find_stream_info fail";
        return meta;
    }

    QVariantList streams;
    quint64 duration=fmt_ctx->duration;

    for (uint i = 0; i < fmt_ctx->nb_streams; i++) {
        QVariantMap smeta;

        qDebug() << "stream info for" << i;

        const auto *stream = fmt_ctx->streams[i];

        qDebug() << "start_time" << stream->start_time;
        qDebug() << "duration" << stream->duration;
        qDebug() << "codec" << stream->codecpar->codec_type;

        smeta.insert("codec", stream->codecpar->codec_type);

        const auto &factor = stream->time_base;

        if (stream->duration > 0 && factor.num > 0 && factor.den > 0) {
            auto dur=quint64(1000000) * stream->duration * factor.num / factor.den;
            qDebug() << "duration adjusted" << dur/1000.0;
            duration=qMax(duration, dur);
        } else if (stream->duration < 0) {
            const auto dur = av_dict_get(stream->metadata, "DURATION", nullptr, 0);
            qDebug() << "duration from stream metadata" << dur->value;
        }
        streams.insert(i, smeta);
    }
    meta.insert("duration", duration/1000.0);
    meta.insert("streams", streams);

    avformat_free_context(fmt_ctx);
#endif

    qDebug() << meta;

    return meta;
}

bool FileReader::read(QUrl file)
{
    QFile f(file.toLocalFile());

    if (!f.open(QIODevice::ReadOnly))
        return true;

    m_data=f.readAll();
    f.close();

    return m_data.isEmpty();
}

QByteArray FileReader::data()
{
    return m_data;
}

void FileReader::clear()
{
    m_data.clear();
}
