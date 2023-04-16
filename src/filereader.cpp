#include "filereader.h"

#include <QDebug>


#ifdef FFMPEG
extern "C" {
#include <libavformat/avformat.h>
#include <libavutil/dict.h>
}
#endif

FileReader::FileReader(QObject *parent)
    : QObject{parent}
{

}

int FileReader::getMetaData(const QString file)
{
#ifdef FFMPEG
    AVFormatContext *fmt_ctx = NULL;
    AVDictionaryEntry *tag = NULL;
    int ret;

    if ((ret = avformat_open_input(&fmt_ctx, file.toLocal8Bit().data(), NULL, NULL)))
        return ret;        

    qDebug() << "format" << fmt_ctx->iformat->name;
    qDebug() << "duration" << fmt_ctx->duration;
    qDebug() << "bitrate" << fmt_ctx->bit_rate;
    qDebug() << "streams" << fmt_ctx->nb_streams;        

    while ((tag = av_dict_get(fmt_ctx->metadata, "", tag, AV_DICT_IGNORE_SUFFIX)))
        qDebug() << tag->key << tag->value;

    if (avformat_find_stream_info(fmt_ctx,  NULL) < 0) {
        qDebug() << "avformat_find_stream_info fail";
        return -1;
    }

    for (int i = 0; i < fmt_ctx->nb_streams; i++) {
        qDebug() << "stream info for" << i;

        const auto *stream = fmt_ctx->streams[i];

        qDebug() << "start_time" << stream->start_time;
        qDebug() << "duration" << stream->duration;
        qDebug() << "codec" << stream->codecpar->codec_type;

        const auto &factor = stream->time_base;

        if (stream->duration > 0 && factor.num > 0 && factor.den > 0) {
            auto dur=qint64(1000000) * stream->duration * factor.num / factor.den;
            qDebug() << "duration adjusted" << dur/1000.0;
        } else if (stream->duration < 0) {
            const auto duration = av_dict_get(stream->metadata, "DURATION", nullptr, 0);
            qDebug() << "duration from metadata" << duration;
        }

    }

    avformat_free_context(fmt_ctx);
#endif
    return 0;
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
