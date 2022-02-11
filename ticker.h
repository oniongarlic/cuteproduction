#ifndef TICKER_H
#define TICKER_H

#include <QObject>
#include <QTimer>

class Ticker : public QTimer
{
    Q_OBJECT
    Q_PROPERTY(int seconds READ seconds NOTIFY secondsChanged)
    Q_PROPERTY(int countdown READ countdown NOTIFY countdownChanged)
public:
    explicit Ticker(QObject *parent = nullptr);

    Q_INVOKABLE void reset();
    Q_INVOKABLE void setAlarm(long seconds);
    Q_INVOKABLE void setCountdownSeconds(long seconds);
    Q_INVOKABLE long seconds() { return m_seconds; };
    Q_INVOKABLE long countdown() { return m_counter; };

    Q_INVOKABLE void start();
    Q_INVOKABLE void resume();
    Q_INVOKABLE void stop();

signals:
    void secondsChanged(long seconds);
    void countdownChanged(long seconds);
    void alarm();
    void zero();

protected:
    void ticker();

private:
    timespec m_ts,m_tm;    
    long m_counter;
    long m_start;
    long m_seconds;
    long m_alarm;
};

#endif // TICKER_H
