import QtQuick 2.0
import Sailfish.Silica 1.0

ListModel {
    property bool ready: false
    ListElement {
        loading: false
        connected: true
        displayName: "Crypto USB token"
        name: "com.company.secrets.plugin.encryptedstorage.crypto"
        supportsLocking: true
        supportsChangingLockCode: true
        keysReady: true
        keysLocked: false
        keysError: false
        keyCount: 2
    }
    ListElement {
        loading: false
        connected: true
        displayName: "Unprotected SIM card"
        name: "com.company.secrets.plugin.storage.sim"
        supportsLocking: false
        supportsChangingLockCode: false
        keysReady: true
        keysError: false
        keysLocked: false
        keyCount: 1
    }
    ListElement {
        loading: false
        connected: true
        displayName: "Keys locked"
        name: "com.company.secrets.plugin.storage.name"
        supportsLocking: true
        supportsChangingLockCode: true
        keysReady: true
        keysError: false
        keysLocked: true
        keyCount: -1
    }
    ListElement {
        loading: false
        connected: true
        displayName: "Fetching keys"
        name: "com.company.secrets.plugin.storage.name"
        supportsLocking: true
        lockCodeRequired: false
        supportsChangingLockCode: false
        keysReady: false
        keysError: false
        keysLocked: false
        keyCount: -1
    }
    ListElement {
        loading: false
        connected: true
        displayName: "Keys error"
        name: "com.company.secrets.plugin.storage.name"
        supportsLocking: true
        supportsChangingLockCode: false
        keysReady: true
        keysError: true
        keysLocked: false
        keyCount: -1
    }
    ListElement {
        loading: false
        connected: true
        displayName: "Empty device"
        name: "com.company.secrets.plugin.storage.name"
        supportsLocking: false
        supportsChangingLockCode: false
        keysReady: true
        keysError: false
        keysLocked: false
        keyCount: 0
    }
    ListElement {
        loading: true
        connected: true
        displayName: "Device initializing"
        name: "com.company.secrets.plugin.storage.name"
        supportsLocking: true
        supportsChangingLockCode: true
        keysReady: false
        keysError: false
        keysLocked: true
        keyCount: -1
    }
    ListElement {
        loading: false
        connected: false
        displayName: "Disconnected device"
        name: "com.company.secrets.plugin.storage.name"
        supportsLocking: true
        supportsChangingLockCode: true
        keysReady: true
        keysError: false
        keysLocked: false
        keyCount: -1
    }
}
