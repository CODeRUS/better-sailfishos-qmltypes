/*
 * Copyright (c) 2015 - 2019 Jolla Ltd.
 *
 * License: Proprietary
 */

import QtQuick 2.0
import Sailfish.Silica 1.0
import MeeGo.Connman 0.2
import Nemo.Ssu 1.1 as Ssu

Item {
    id: root

    function personalizeBroadcastNames() {
        wifiTechnology.tetheringId = Ssu.DeviceInfo.displayName(Ssu.DeviceInfo.DeviceModel)
    }

    NetworkManagerFactory {
        id: networkManager
    }

    Connections {
        target: networkManager.instance
        onTechnologiesChanged: wifiTechnology.path = networkManager.instance.technologyPathForType("wifi")
    }

    NetworkTechnology {
        id: wifiTechnology
        path: networkManager.instance.technologyPathForType("wifi")
    }
}
