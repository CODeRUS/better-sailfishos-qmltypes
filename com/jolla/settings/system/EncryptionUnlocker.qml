/****************************************************************************
**
** Copyright (c) 2020 Open Mobile Platform LLC.
** License: Proprietary
**
****************************************************************************/

import Nemo.DBus 2.0
import QtQml 2.2

QtObject {
    function unlock(parent, objectPath) {
        _unlockerComponent.createObject(parent, { "objectPath" : objectPath })
    }

    property Component _unlockerComponent: Component {
        DBusInterface {
            id: unlocker

            property string objectPath
            property var blockData
            property var driveData

            function _showUnlockUi(driveData) {
                var deviceData = {
                    "label": blockData.IdLabel,
                    "size": blockData.Size,
                    "mountable": false,
                    "encrypted": true,
                    "vendor": driveData.Vendor,
                    "model": driveData.Model,
                    "connectionBus": driveData.ConnectionBus,
                    "objectPath": objectPath
                }

                bus = DBus.SessionBus
                service = "com.jolla.windowprompt"
                iface = "com.jolla.windowprompt"
                path = "/com/jolla/windowprompt"

                call("showStorageDevicePrompt", [deviceData], unlocker.destroy, unlocker.destroy)
            }

            function _unlock() {
                bus = DBus.SystemBus
                service = "org.freedesktop.UDisks2"
                iface = "org.freedesktop.DBus.Properties"
                path = objectPath

                blockData = null
                driveData = null

                call("GetAll", ["org.freedesktop.UDisks2.Block"],
                     function(conf) {
                         blockData = conf
                         path = blockData.Drive
                         unlocker.call("GetAll", ["org.freedesktop.UDisks2.Drive"], _showUnlockUi, unlocker.destroy)
                     }, unlocker.destroy)
            }

            Component.onCompleted: _unlock()
        }
    }
}
