/*
 * Copyright (c) 2019 Jolla Ltd.
 *
 * License: Proprietary
 */

import QtQuick 2.0
import Nemo.DBus 2.0
import Nemo.FileManager 1.0
import org.nemomobile.configuration 1.0
import Sailfish.Encryption 1.0

DBusInterface {
    id: encryptionService

    bus: DBus.SystemBus
    service: "org.sailfishos.EncryptionService"
    path: "/org/sailfishos/EncryptionService"
    iface: "org.sailfishos.EncryptionService"
    signalsEnabled: true
    // Prevents automatic introspection but simplifies the code otherwise
    watchServiceStatus: true

    property string errorString
    property string errorMessage
    property int encryptionStatus
    property bool serviceSeen
    readonly property bool encryptionWanted: encryptHome.exists && (status !== DBusInterface.Unavailable || serviceSeen)
    readonly property bool available: encryptHome.exists && (status === DBusInterface.Available || serviceSeen)
    readonly property bool busy: encryptionWanted && encryptionStatus == EncryptionStatus.Busy

    onStatusChanged: if (status === DBusInterface.Available) serviceSeen = true

    // DBusInterface is a QObject so no child items
    property FileWatcher encryptHome: FileWatcher {
        id: encryptHome
        fileName: "/var/lib/sailfish-device-encryption/encrypt-home"
    }

    // This introspects the interface. Thus, starting the dbus service.
    readonly property DBusInterface introspectAtStart: DBusInterface {
        bus: DBus.SystemBus
        service: encryptionService.service
        path: encryptionService.path
        iface: "org.freedesktop.DBus.Introspectable"
        Component.onCompleted: call("Introspect")
    }

    onAvailableChanged: {
        // Move to busy state right after service is available. So that
        // user do not see text change from Idle to Busy (encryption is started
        // when we hit the PleaseWaitPage).
        if (available) {
            encryptionStatus = EncryptionStatus.Busy
        }
    }

    function encrypt() {
        call("BeginEncryption", undefined,
             function() {
                 encryptionStatus = EncryptionStatus.Busy
             },
             function(error, message) {
                 errorString = error
                 errorMessage = message
                 encryptionStatus = EncryptionStatus.Error
             }
        )
    }

    function finalize() {
        call("FinalizeEncryption")
    }

    function prepare(passphrase, overwriteType) {
        call("PrepareToEncrypt", [passphrase, overwriteType])
    }

    function encryptionFinished(success, error) {
        encryptionStatus = success ? EncryptionStatus.Encrypted : EncryptionStatus.Error
    }
}
