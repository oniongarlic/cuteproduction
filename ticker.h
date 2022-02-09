#ifndef TICKER_H
#define TICKER_H

#include <QObject>
#include <QTimer>

class Ticker : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int seconds READ seconds NOTIFY secondsChanged)
public:
    explicit Ticker(QObject *parent = nullptr);

    Q_INVOKABLE void reset();
    Q_INVOKABLE void setAlarm(long seconds);
    Q_INVOKABLE long seconds() { return m_seconds; };
    Q_INVOKABLE void start();
    Q_INVOKABLE void stop();

signals:
    void secondsChanged(long seconds);

protected:
    void ticker();

private:
    timespec m_ts,m_tm;
    long m_counter;
    long m_start;
    long m_seconds;
    QTimer *timer;
};

#endif // TICKER_H
