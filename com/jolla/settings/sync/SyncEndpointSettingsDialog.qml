import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.settings.sync 1.0

Dialog {
    id: root

    property string identifier
    property bool isNewEndpoint
    property bool autoDismiss

    signal saveAndSync(var endpointProps)
    signal remove(string identifier)

    onStatusChanged: {
        if (status == PageStatus.Active && autoDismiss) {
            pageStack.pop()
        }
    }

    onAutoDismissChanged: {
        if (status == PageStatus.Active && autoDismiss) {
            pageStack.pop()
        }
    }

    onAccepted: {
        var direction = endpoint.direction
        switch (directionCombo.currentIndex) {
        case 0:
            direction = SyncEndpoint.TwoWaySync
            break
        case 1:
            direction = SyncEndpoint.DownloadSync
            break
        case 2:
            direction = SyncEndpoint.UploadSync
            break
        }
        var syncDataTypes = 0
        if (contactsSwitch.checked) {
            syncDataTypes |= SyncEndpoint.SyncContacts
        }
        if (calendarsSwitch.checked) {
            syncDataTypes |= SyncEndpoint.SyncCalendars
        }
        var endpointProps = {
            "identifier": endpoint.identifier,
            "direction": direction,
            "syncDataTypes": syncDataTypes
        }
        saveAndSync(endpointProps)
    }

    SyncEndpoint {
        id: endpoint
        identifier: root.identifier
    }

    BusyIndicator {
        anchors.centerIn: parent
        size: BusyIndicatorSize.Large
        running: root.identifier == ""
    }

    SilicaFlickable {
        id: flick
        anchors.fill: parent
        contentHeight: col.height
        contentWidth: width
        opacity: root.identifier == "" ? 0 : 1
        Behavior on opacity { FadeAnimation {} }

        PullDownMenu {
            visible: !root.isNewEndpoint
            enabled: visible

            MenuItem {
                //: Removes the sync endpoint
                //% "Remove"
                text: qsTrId("settings_sync-me-remove_endpoint")
                onClicked: {
                    if (root === pageStack.currentPage) {
                        pageStack.pop()
                    }
                    root.remove(root.identifier)
                }
            }
        }

        DialogHeader {
            id: dialogHeader
            dialog: root

            // Clicking on this will save the selected settings and trigger a sync
            //% "Sync"
            title: qsTrId("settings_sync-he-sync")
        }

        Column {
            id: col
            width: parent.width
            anchors.top: dialogHeader.bottom

            SyncEndpointDelegate {
                endpointData: endpoint
            }

            TextSwitch {
                id: contactsSwitch
                //: Select this option to sync contacts
                //% "Contacts"
                text: qsTrId("settings_sync-sw-contacts")
                checked: endpoint.syncDataTypes & SyncEndpoint.SyncContacts
            }

            TextSwitch {
                id: calendarsSwitch
                //: Select this option to sync calendar events
                //% "Calendar events"
                text: qsTrId("settings_sync-sw-calendar_events")
                checked: endpoint.syncDataTypes & SyncEndpoint.SyncCalendars
            }

            ComboBox {
                id: directionCombo
                width: parent.width
                currentIndex: {
                    switch (endpoint.direction) {
                    case SyncEndpoint.TwoWaySync:
                        return 0
                    case SyncEndpoint.DownloadSync:
                        return 1
                    case SyncEndpoint.UploadSync:
                        return 2
                    }
                }

                //: Determines the direction in which sync operations will be performed (two-way, upload only, or download only)
                //% "Direction:"
                label: qsTrId("settings_sync-la-direction")
                menu: ContextMenu {
                    MenuItem {
                        //: Sync mode in which the Jolla device will send data to, and also receive data from, the other device
                        //% "Two-way sync"
                        text: qsTrId("settings_sync-la-twoway")
                    }
                    MenuItem {
                        //: Sync mode in which the Jolla device will receive data from the other device (but will not send any)
                        //% "One-way from %1"
                        text: qsTrId("settings_sync-la-one_way_from_remote").arg(endpoint.name)
                    }
                    MenuItem {
                        //: Sync mode in which the Jolla device will send data to the other device (but will not receive any data back)
                        //% "One-way to %1"
                        text: qsTrId("settings_sync-la-one_way_to_remote").arg(endpoint.name)
                    }
                }
            }
        }
    }
}
