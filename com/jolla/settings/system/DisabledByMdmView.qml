/*
 * Copyright (c) 2013 - 2019 Jolla Ltd.
 * Copyright (c) 2019 Open Mobile Platform LLC.
 *
 * License: Proprietary
 */
import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.systemsettings 1.0

Loader {
    property string activity
    enabled: false
    anchors.fill: parent
    active: opacity > 0.0
    opacity: enabled ? 1.0 : 0.0
    Behavior on opacity { FadeAnimation { duration: 400 } }

    sourceComponent: Rectangle {
        color: Theme.rgba(Theme.highlightDimmerColor, Theme.opacityOverlay)

        TouchBlocker {
            anchors.fill: parent
            target: parent
        }

        Image {
            source: "image://theme/icon-m-device-lock?" + Theme.highlightColor
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: lockedLabel.top
                bottomMargin: Theme.paddingMedium
            }
        }

        Label {
            id: lockedLabel
            x: Theme.horizontalPageMargin
            width: parent.width - 2*Theme.horizontalPageMargin
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: Theme.fontSizeExtraLarge
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            //: %1 is the name of the disabled action, %2 is an operating system name without the OS suffix
            //% "%1 disabled by %2 Device Manager."
            text: qsTrId("settings_system-la-activity_disabled_by_device_manager")
                .arg(activity)
                .arg(aboutSettings.baseOperatingSystemName)
            color: Theme.highlightColor
        }
    }

    AboutSettings {
        id: aboutSettings
    }
}
