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

    while ((tag = av_dict_get(fmt_ctx->metadata, "", tag, AV_DICT_IGNORE_SUFFIX)))
        qDebug() << tag->key << tag->value;

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
