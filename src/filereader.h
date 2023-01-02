#ifndef FILEREADER_H
#define FILEREADER_H

#include <QObject>
#include <QFile>
#include <QUrl>

class FileReader : public QObject
{
    Q_OBJECT
public:
    explicit FileReader(QObject *parent = nullptr);

    Q_INVOKABLE QByteArray data();
    Q_INVOKABLE bool read(QUrl file);
    Q_INVOKABLE void clear();

    Q_INVOKABLE int getMetaData(const QString file);
signals:

private:
    QByteArray m_data;

};

#endif // FILEREADER_H
