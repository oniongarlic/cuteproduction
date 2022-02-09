#include "ticker.h"

Ticker::Ticker(QObject *parent)
    : QObject{parent}, m_seconds(0)
{    
    timer = new QTimer(this);
    connect(timer, &QTimer::timeout, this, &Ticker::ticker);
    timer->start(1000);

    reset();
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
    timer->start();
}

void Ticker::stop()
{
    timer->stop();
}

void Ticker::ticker()
{
    clock_gettime(CLOCK_MONOTONIC, &m_tm);

    m_seconds=m_tm.tv_sec-m_start;

    emit secondsChanged(m_seconds);
}
