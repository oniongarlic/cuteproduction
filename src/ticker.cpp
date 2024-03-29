#include "ticker.h"

Ticker::Ticker(QObject *parent)
    : QTimer{parent}, m_counter(0), m_seconds(0), m_alarm(0)
{        
    connect(this, &QTimer::timeout, this, &Ticker::ticker);
    reset();
    setInterval(1000);
    setTimerType(Qt::PreciseTimer);
}

void Ticker::reset()
{
#if defined __MINGW32__ || defined Q_OS_UNIX
    clock_gettime(CLOCK_MONOTONIC, &m_tm);
    m_start=m_tm.tv_sec;
#else
    m_start=0;
#endif
    m_seconds=0;
    emit secondsChanged(m_seconds);
}

void Ticker::setAlarm(long seconds)
{
    m_alarm=seconds;
}

void Ticker::setCountdownSeconds(long seconds)
{
    m_counter=seconds;
    if (m_counter<0)
        m_counter=0;
    emit countdownChanged(m_counter);
}

void Ticker::addCountdownSeconds(long seconds)
{
    m_counter+=seconds;
    if (m_counter<0)
        m_counter=0;
    emit countdownChanged(m_counter);
}

void Ticker::start()
{
    reset();
    QTimer::start();
    emit activeChanged();
}

void Ticker::resume()
{
    QTimer::start();
    emit activeChanged();
}

void Ticker::stop()
{
    QTimer::stop();
    emit activeChanged();
}

void Ticker::ticker()
{
#if defined __MINGW32__ || defined Q_OS_UNIX
    clock_gettime(CLOCK_MONOTONIC, &m_tm);
    m_seconds=m_tm.tv_sec-m_start;
#else
    m_seconds++;
#endif
    emit secondsChanged(m_seconds);

    if (m_counter>0) {
        m_counter--;
        emit countdownChanged(m_counter);
        if (m_counter==0)
            emit zero();
    }

    if (m_alarm>0 && m_seconds==m_alarm) {
        emit alarm();
    }
}

bool Ticker::isActive() const
{
    return QTimer::isActive();
}
