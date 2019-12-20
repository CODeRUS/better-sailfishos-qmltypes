import QtQuick 2.2
import QtQuick.Window 2.1 as QtQuick
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0 as Private
import Sailfish.Lipstick 1.0

Private.Slideable {
    id: pannable

    property int orientation: QtQuick.Screen.primaryOrientation
    property int _effectiveOrientation
    onOrientationChanged: {
        if (!moving) {
            _effectiveOrientation = orientation
        }
    }

    flow: QtQuick.Screen.angleBetween(
                _effectiveOrientation, QtQuick.Screen.primaryOrientation)

    property alias peekFilter: peekFilter

    onMovementEnded: {
        _effectiveOrientation = orientation
    }

    dragArea.states: [
        State {
            name: "leftPeek"
            when: (peekFilter.leftActive && !pannable._inverted)
                        || (peekFilter.rightActive && pannable._inverted)
            PropertyChanges {
                target: pannable
                absoluteProgress: peekFilter.absoluteProgress
            }
        }, State {
            name: "rightPeek"
            when: (peekFilter.leftActive && pannable._inverted)
                        || (peekFilter.rightActive && !pannable._inverted)
            PropertyChanges {
                target: pannable
                absoluteProgress: -peekFilter.absoluteProgress
            }
        }
    ]

    PeekFilter {
        id: peekFilter

        leftEnabled: true
        rightEnabled: true
        objectName: "pannablePeekFilter"
    }
}
