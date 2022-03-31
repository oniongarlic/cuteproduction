#include "html.h"

#include <QTextDocumentFragment>

html::html(QObject *parent)
    : QObject{parent}
{

}

QString html::stripTags(QString html)
{
return QTextDocumentFragment::fromHtml(html).toPlainText();
}
