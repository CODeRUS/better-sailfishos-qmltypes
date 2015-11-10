/****************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Petri M. Gerdt <petri.gerdt@jollamobile.com>
**
****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.dbus 1.0

QtObject {
    property int selectionCount
    property var selectedApplications: []

    property var appsBeingInstalled: []

    function updateApplicationSelection(packageName, selected) {
        var index = selectedApplications.indexOf(packageName);
        if (selected && index < 0) {
            selectedApplications.push(packageName);
            selectionCount++
        } else if (!selected && index > -1) {
            selectedApplications.splice(index, 1);
            selectionCount--
        }
    }

    function installSelectedApps() {
        for (var i = 0; i < selectedApplications.length; i++) {
            if (appsBeingInstalled.indexOf(selectedApplications[i]) < 0) {
                appsBeingInstalled.push(selectedApplications[i])
                _storeClientInterface.call("installPackage", selectedApplications[i])
            }
        }
    }

    property DBusInterface _storeClientInterface: DBusInterface {
        destination: "com.jolla.jollastore"
        path: "/StoreClient"
        iface: "com.jolla.jollastore"
    }
}
