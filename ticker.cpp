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
    clock_gettime(CLOCK_MONOTONIC, &m_tm);
    m_start=m_tm.tv_sec;
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
    emit countdownChanged(m_counter);
}

void Ticker::start()
{
    reset();
    QTimer::start();
}

void Ticker::resume()
{
    QTimer::start();
}

void Ticker::stop()
{
    QTimer::stop();
}

void Ticker::ticker()
{
    clock_gettime(CLOCK_MONOTONIC, &m_tm);

    m_seconds=m_tm.tv_sec-m_start;

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
