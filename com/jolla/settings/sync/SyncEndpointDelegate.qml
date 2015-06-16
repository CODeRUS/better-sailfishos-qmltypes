import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.settings.sync 1.0

Item {
    id: root

    property QtObject endpointData
    property bool interactive

    property string identifier
    property string icon: endpointData ? endpointData.icon : ""
    property string name: endpointData ? endpointData.name : ""
    property var lastSync: endpointData ? endpointData.lastSync: undefined
    property int status: endpointData ? endpointData.status : SyncEndpoint.UnknownStatus

    function _statusText() {
        switch (status) {
        case SyncEndpoint.Queued:
            //: Displayed when the sync operation is currently queued
            //% "Waiting to sync"
            return qsTrId("settings_sync-la-sync_waiting")
        case SyncEndpoint.Syncing:
            // (Note: revert to this 'Syncing' text when we can sync more than just contacts)
            //: Displayed when the sync operation is in progress
            //% "Syncing"
            var s = qsTrId("settings_sync-la-syncing")

            //: Displayed when in the process of transferring contacts from another device
            //% "Receiving contacts"
            return qsTrId("settings_sync-la-download_contacts")
        case SyncEndpoint.UnknownStatus:
        case SyncEndpoint.Succeeded:
            if (lastSync && lastSync.toString() !== "Invalid Date") {
                //: Shows the last time this sync operation was completed successfully
                //% "Last sync: %1"
                return qsTrId("settings_sync-la-last_sync_date").arg(Format.formatDate(lastSync, Format.TimepointRelativeCurrentDay))
            }
            if (status == SyncEndpoint.Succeeded) {
                //: Displayed if the device successfully synced to the endpoint
                //% "Success"
                return qsTrId("settings_sync-la-success")
            }
            return ""
        case SyncEndpoint.Failed:
            //: Displayed if the sync operation failed
            //% "Sync failed"
            return qsTrId("settings_sync-la-sync_failed")
        case SyncEndpoint.Canceled:
            //: Displayed if the sync operation was canceled
            //% "Sync canceled"
            return qsTrId("settings_sync-la-sync_canceled")
        default:
            return "unknown"
        }
    }

    width: parent.width
    height: Theme.itemSizeLarge

    Image {
        id: iconImage
        x: Theme.horizontalPageMargin
        y: parent.height/2 - height/2
        source: root.icon
    }

    Label {
        id: deviceNameLabel
        anchors {
            left: iconImage.right
            leftMargin: Theme.paddingMedium
            right: busySpinner.running ? busySpinner.left : parent.right
            rightMargin: Theme.paddingLarge
            verticalCenter: parent.verticalCenter
            verticalCenterOffset: syncStatusLabel.text !== "" ? -syncStatusLabel.implicitHeight/2 : 0
        }
        color: root.interactive ? Theme.primaryColor: Theme.highlightColor
        truncationMode: TruncationMode.Fade
        text: root.name.length
              ? root.name
                //: Default text for a Bluetooth device that does not have a name
                //% "Unnamed device"
              : qsTrId("settings_sync-la-unnamed_device")
    }

    Label {
        id: syncStatusLabel
        anchors {
            top: deviceNameLabel.bottom
            left: deviceNameLabel.left
            right: busySpinner.running ? busySpinner.left : parent.right
            rightMargin: busySpinner.running ? Theme.paddingMedium : Theme.horizontalPageMargin
        }
        truncationMode: TruncationMode.Fade
        color: root.status == SyncEndpoint.Failed ? Theme.highlightColor : Theme.secondaryColor
        text: root._statusText()
    }

    BusyIndicator {
        id: busySpinner
        running: root.status == SyncEndpoint.Syncing || root.status == SyncEndpoint.Queued
        size: BusyIndicatorSize.Medium
        anchors {
            verticalCenter: iconImage.verticalCenter
            right: parent.right
            rightMargin: Theme.horizontalPageMargin
        }
    }
}
