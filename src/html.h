#ifndef HTML_H
#define HTML_H

#include <QObject>

class html : public QObject
{
    Q_OBJECT
public:
    explicit html(QObject *parent = nullptr);

    Q_INVOKABLE QString stripTags(QString html);

signals:

};

#endif // HTML_H
