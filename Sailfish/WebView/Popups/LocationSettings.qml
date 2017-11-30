/****************************************************************************
**
** Copyright (C) 2016 Jolla Ltd.
** Contact: Raine Makelainen <raine.makelainen@jolla.com>
**
****************************************************************************/

/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this file,
 * You can obtain one at http://mozilla.org/MPL/2.0/. */

pragma Singleton
import QtQml 2.2
import org.nemomobile.systemsettings 1.0

QtObject {
    id: root

    property bool locationEnabled: locationSettings.locationEnabled
                                   && ((locationSettings.gpsEnabled && !locationSettings.gpsFlightMode)
                                       || locationSettings.mlsEnabled
                                       || locationSettings.hereState == LocationSettings.OnlineAGpsEnabled)

    property LocationSettings l: LocationSettings {
        id: locationSettings
    }
}
