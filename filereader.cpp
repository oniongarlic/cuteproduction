
#include "filereader.h"

FileReader::FileReader(QObject *parent)
    : QObject{parent}
{

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
