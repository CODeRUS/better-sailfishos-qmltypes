import QtQuick 2.0
import Sailfish.Silica 1.0

GlassItem {
    id: root

    property real value
    property int stepCount: 12
    property int rotationRadius
    property bool highlighted
    property real velocity: 30
    property bool animationEnabled: true
    property bool moving

    function _xTranslation(value, bound) {
        // Use sine to map range of 0-bound to the X translation of a circular locus (-1 to 1)
        return Math.sin((value % bound) / bound * Math.PI * 2)
    }

    function _yTranslation(value, bound) {
        // Use cosine to map range of 0-bound to the Y translation of a circular locus (-1 to 1)
        return Math.cos((value % bound) / bound * Math.PI * 2)
    }

    falloffRadius: Theme.colorScheme === Theme.DarkOnLight ? 0.20 : 0.22
    radius: Theme.colorScheme === Theme.DarkOnLight ? 0.22 : 0.25

    color: !highlighted ? Theme.lightPrimaryColor : Theme.colorScheme === Theme.DarkOnLight ? Theme.highlightDimmerColor
                                                                                            : Theme.highlightColor
    backgroundColor: Theme.colorScheme === Theme.DarkOnLight ? Theme.highlightDimmerColor : "transparent"

    transform: Translate {
        x: root.rotationRadius * _xTranslation(root.value, root.stepCount)
        y: -root.rotationRadius * _yTranslation(root.value, root.stepCount)
    }

    Behavior on value {
        SmoothedAnimation { velocity: root.velocity }
        enabled: root.animationEnabled && !root.moving
    }
}
