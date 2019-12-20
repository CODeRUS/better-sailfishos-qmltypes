/*
 * Copyright (c) 2019 Open Mobile Platform LLC.
 *
 * License: Proprietary
 */

import QtQuick 2.0
import Sailfish.Silica 1.0

Rectangle {
    gradient: Gradient {
        GradientStop { position: 0.0; color: Theme.primaryColor }
        GradientStop {
            position: 1.0
            color: Qt.tint(Theme.highlightDimmerColor,
                           Theme.rgba(Theme.primaryColor, Theme.opacityLow))
        }
    }
}
