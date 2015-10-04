import QtQuick 2.0
import Sailfish.Silica 1.0
import MeeGo.Connman 0.2
import org.freedesktop.contextkit 1.0
import org.nemomobile.lipstick 0.1

Item {
    id: connectionStatusIndicator
    property bool enabled
    property bool hasCellularCapability: mobileNetworkTechnology.path !== ""

    width: primaryIcon.width
    height: primaryIcon.height

    visible: primaryIcon.status == Image.Ready || secondaryIcon.status == Image.Ready

    ContextProperty {
        id: tetheringInterface
        key: "Internet.Tethering"
    }

    property string _wlanIconId: {
        // WLAN off
        if (!wlanNetworkTechnology.powered)
            return "";

        // WLAN tethering
        if (tetheringInterface.value === "wifi")
            return "";

        // WLAN connected
        if (wlanNetworkTechnology.connected) {
            if (networkManager.defaultRoute.type !== "wifi" && networkManager.defaultRoute.type !== "")
                return "icon-status-wlan-0"

            if (networkManager.defaultRoute.strength >= 59) {
                return "icon-status-wlan-4"
            } else if (networkManager.defaultRoute.strength >= 55) {
                return "icon-status-wlan-3"
            } else if (networkManager.defaultRoute.strength >= 50) {
                return "icon-status-wlan-2"
            } else if (networkManager.defaultRoute.strength >= 40) {
                return "icon-status-wlan-1"
            } else {
                return "icon-status-wlan-0"
            }
        }

        // WLAN not connected, network available
        if (networkManager.servicesList("wifi").length > 0)
            return "icon-status-wlan-available"

        // WLAN no signal
        return "icon-status-wlan-no-signal"
    }

    property string _cellularIconId: {
        // Cellular off
        if (!mobileNetworkTechnology.powered)
            return ""

        // Cellular connected
        if (mobileNetworkTechnology.connected) {
            if (mobileNetworkTechnology.uploading && mobileNetworkTechnology.downloading) {
                // Mobile data, bi-directional traffic
                return "icon-status-data-traffic"
            } else if (mobileNetworkTechnology.uploading) {
                // Mobile data, uploading data
                return "icon-status-data-upload"
            } else if (mobileNetworkTechnology.downloading) {
                // Mobile data, downloading data
                return "icon-status-data-download"
            } else {
                // Mobile data enabled, inactive
                return "icon-status-data-no-traffic"
            }
        }

        return ""
    }

    Image {
        id: primaryIcon

        opacity: blinkIconTimer.primaryIconVisible ? 1 : 0
        width: iconWidth
        height: iconWidth
        sourceSize: iconSize
        source: {
            if (internetNetworkType.value === "WLAN" && _wlanIconId !== "")
                return "image://theme/" + _wlanIconId + iconSuffix
            else if (internetNetworkType.value === "GPRS" && _cellularIconId !== "")
                return "image://theme/" + _cellularIconId + iconSuffix
            else if (internetNetworkType.value === "" && _cellularIconId !== "")
                return "image://theme/" + _cellularIconId + iconSuffix
            else if (internetNetworkType.value === "" && _wlanIconId !== "")
                return "image://theme/" + _wlanIconId + iconSuffix
            else
                return ""
        }

        Behavior on opacity { FadeAnimation { } }
        anchors.bottom: parent.bottom
    }

    Image {
        id: secondaryIcon
        width: iconWidth
        height: iconWidth
        sourceSize: iconSize
        source: {
            if (internetNetworkType.value === "WLAN" && _cellularIconId !== "")
                return "image://theme/" + _cellularIconId + iconSuffix
            else if (internetNetworkType.value === "GPRS" && _wlanIconId !== "")
                return "image://theme/" + _wlanIconId + iconSuffix
            else
                return ""
        }

        opacity: 1 - primaryIcon.opacity
        anchors.bottom: parent.bottom
    }

    Image {
        id: tetheringOverlay
        width: iconWidth
        height: iconWidth
        sourceSize: iconSize
        source: "image://theme/icon-status-data-share" + iconSuffix
        visible: tetheringInterface.value === "wifi"
        anchors.bottom: parent.bottom
    }

    Timer {
        id: blinkIconTimer

        property bool primaryIconVisible: true

        interval: 1000
        repeat: true
        running: wlanNetworkTechnology.powered && wlanNetworkTechnology.connected &&
                 _wlanIconId !== "" && _cellularIconId !== "" &&
                 _cellularIconId !== "icon-status-data-no-traffic"
        onRunningChanged: {
            if (!running)
                primaryIconVisible = true
        }

        onTriggered: primaryIconVisible = !primaryIconVisible
    }

    NetworkManager {
        id: networkManager

        property bool technologyPathsValid: wlanNetworkTechnology.path !== "" && mobileNetworkTechnology.path !== ""

        function updateTechnologies() {
            if (available && technologiesEnabled) {
                wlanNetworkTechnology.path = networkManager.technologyPathForType("wifi")
                mobileNetworkTechnology.path = networkManager.technologyPathForType("cellular")
            }
        }

        onAvailableChanged: updateTechnologies()
        onTechnologiesEnabledChanged: updateTechnologies()
        onTechnologiesChanged: updateTechnologies()

        servicesEnabled: !technologyPathsValid || connectionStatusIndicator.enabled
        technologiesEnabled: !technologyPathsValid || connectionStatusIndicator.enabled
    }

    NetworkTechnology {
        id: wlanNetworkTechnology
    }

    NetworkTechnology {
        id: mobileNetworkTechnology

        property bool uploading: false
        property bool downloading: false
    }

    ContextProperty {
        id: internetNetworkType
        key: "Internet.NetworkType"
    }

    Timer {
        id: downloadCounterTimer

        interval: 2100

        onTriggered: {
            mobileNetworkTechnology.downloading = false
        }
    }

    Timer {
        id: uploadCounterTimer

        interval: 2100

        onTriggered: {
            mobileNetworkTechnology.uploading = false
        }
    }

    NetworkCounter {
        id: usageCounter

        // Avoid dynamically changing any of accuracy, interval or running.
        // As of now, might cause synchronous operations over dbus to connmand
        accuracy: 10 //update threshold in kilobytes
        interval: 2 // poll in seconds
        running: true

        onCounterChanged: {
            if (servicePath.indexOf("/net/connman/service/cellular_") === 0) {
                if (counters["TX.Bytes"] === undefined) {
                    mobileNetworkTechnology.uploading = false
                    uploadCounterTimer.stop()
                } else {
                    mobileNetworkTechnology.uploading = true
                    uploadCounterTimer.restart()
                }
                if (counters["RX.Bytes"] === undefined) {
                    mobileNetworkTechnology.downloading = false
                    downloadCounterTimer.stop()
                } else {
                    mobileNetworkTechnology.downloading = true
                    downloadCounterTimer.restart()
                }
            }
        }
    }
}
