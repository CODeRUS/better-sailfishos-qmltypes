/****************************************************************************
 **
 ** Copyright (C) 2013-2019 Jolla Ltd.
 ** Copyright (C) 2020 Open Mobile Platform LLC.
 **
 ****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0 as Private
import org.nemomobile.lipstick 0.1

Private.SwipeItem {
    readonly property bool housekeeping: Lipstick.compositor.eventsLayer.housekeeping

    onClicked: if (housekeeping) Lipstick.compositor.eventsLayer.setHousekeeping(false)
    onPressAndHold: if (!housekeeping) Lipstick.compositor.eventsLayer.setHousekeeping(true)

    _showPress: down && !housekeeping
    width: parent.width
}
