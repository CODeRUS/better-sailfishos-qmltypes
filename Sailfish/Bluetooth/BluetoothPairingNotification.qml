import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.notifications 1.0

Notification {
    category: "x-jolla.bluetooth.pairing"

    //: Short error message shown when a bluetooth pairing attempt failed
    //% "Pairing failed"
    previewBody: qsTrId("components_bluetooth-la-pairing_failed_short")
}
