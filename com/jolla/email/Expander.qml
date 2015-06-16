/****************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Valerio Valerio <valerio.valerio@jolla.com>
**
****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0

IconButton {
    id: expander

    property real minimumHeight
    property real maximumHeight

    property real expansion: _expansionRestartValue

    property int clickAnimationDuration: 300
    property int dragAnimationDuration: 200

    property bool dragging: drag.active
    property bool changing: dragging || expansionAnimation.running

    property bool _expanded
    property real _initialExpansion
    property real _expansionRestartValue

    icon.source: "image://theme/icon-lock-more"

    drag.target: expander
    drag.axis: Drag.YAxis
    drag.minimumY: 0
    drag.maximumY: 0

    drag.onActiveChanged: {
        if (drag.active) {
            _initialExpansion = expansion

            // Only start dragging if we're currently at the boundary
            if (expansion < 0.01) {
                // Make sure animation is not running and we're at initial position
                expansionAnimation.complete()
                drag.minimumY = expander.y
                drag.maximumY = expander.y + (maximumHeight - minimumHeight)
            } else if (expansion > 0.99) {
                // Make sure animation is not running and we're at initial position
                expansionAnimation.complete()
                drag.minimumY = expander.y - (maximumHeight - minimumHeight)
                drag.maximumY = expander.y
            }
        } else {
            // Reset drag bounds first in order to get out of "dragging" state
            // before starting the animation (or resetting "expansion")
            drag.maximumY = 0
            drag.minimumY = 0

            // Animate to the final position
            _expansionRestartValue = expansion
            if (_initialExpansion < expansion) {
                _expanded = (expansion > 0.33)
            } else {
                _expanded = (expansion > 0.66)
            }

            // Only animate if we are not already at the boundary
            if (expansion < 0.01) {
                expansion = 0.0
            } else if (expansion > 0.99) {
                expansion = 1.0
            } else {
                expansionAnimation.duration = dragAnimationDuration
                expansionAnimation.easing.type = Easing.OutQuad
                expansionAnimation.restart()
            }
        }
    }

    states: State {
        name: "dragging"
        when: expander.drag.maximumY && expander.drag.maximumY != expander.drag.minimumY
        PropertyChanges {
            target: expander
            expansion: (expander.y - expander.drag.minimumY) / (expander.drag.maximumY - expander.drag.minimumY)
        }
        AnchorChanges {
            target: expander
            anchors { top: undefined; bottom: undefined }
        }
    }

    onClicked: {
        _expanded = !_expanded
        expansionAnimation.duration = clickAnimationDuration
        expansionAnimation.easing.type = Easing.InOutQuad
        expansionAnimation.restart()
    }

    NumberAnimation on expansion {
        id: expansionAnimation
        to: expander._expanded ? 1.0 : 0.0
    }
}
