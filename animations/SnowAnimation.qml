import QtQuick 2.15
import QtQuick.Particles 2.15

ParticleSystem {
    id: sys
    anchors.fill: parent
    running: true
    visible: running

    ImageParticle {
        source: "qrc:///snowflake.png"
        alpha: 0
        // alphaVariation:
        // colorVariation: 0.6
        rotationVariation: 45
        rotationVelocity: 3
        rotationVelocityVariation: 4
    }

    Timer {
        running: sys.running
        interval: 100
        repeat: true
        onTriggered: {
            snowEmitter.x=Math.random()*parent.width
        }
    }

    Emitter {
        id: snowEmitter
        x: parent.width/2
        y: -80
        emitRate: 40
        lifeSpan: 24000
        lifeSpanVariation: 4000
        enabled: true
        velocity: AngleDirection {
            angle: -90
            magnitude: 32;
            magnitudeVariation: 16
            angleVariation: 220
        }
        acceleration: PointDirection {
            xVariation: 2
            yVariation: 3
        }

        size: 32
        sizeVariation: 16
    }

    Wander {
        xVariance: 2
        yVariance: 4
        pace: 0.4
        affectedParameter: PointAttractor.Position
    }
}
