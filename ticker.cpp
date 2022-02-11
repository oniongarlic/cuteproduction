#include "ticker.h"

Ticker::Ticker(QObject *parent)
    : QTimer{parent}, m_seconds(0)
{        
    connect(this, &QTimer::timeout, this, &Ticker::ticker);
    reset();
    setInterval(1000);
}

void Ticker::reset()
{
    m_counter=0;
    clock_gettime(CLOCK_MONOTONIC, &m_tm);
    m_start=m_tm.tv_sec;
    m_seconds=0;
    emit secondsChanged(m_seconds);
}

void Ticker::setAlarm(long seconds)
{

}

void Ticker::start()
{
    reset();
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
}
