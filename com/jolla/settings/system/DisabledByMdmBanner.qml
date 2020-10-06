import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.systemsettings 1.0

Rectangle {
    id: root

    property bool compressed
    property bool active: true
    property bool limited
    property alias text: lockedLabel.text
    property alias font: lockedLabel.font

    width: parent.width
    height: active ? implicitHeight : 0
    opacity: active ? 1.0 : 0.0
    visible: opacity > 0.0
    implicitHeight: lockedLabel.implicitHeight + 2*lockedLabel.y
    color: Theme.rgba(Theme.highlightDimmerColor, 0.5)
    Behavior on opacity { FadeAnimation {} }
    Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }

    Label {
        id: lockedLabel
        y: root.compressed ? Theme.paddingMedium : Theme.paddingLarge
        x: Theme.horizontalPageMargin
        width: parent.width - 2*Theme.horizontalPageMargin
        font.pixelSize: root.compressed ? Theme.fontSizeMedium : Theme.fontSizeExtraLarge
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.Wrap
        textFormat: Text.StyledText
        text: {
            if (!limited) {
                //: %1 is operating system name without OS suffix
                //% "Disabled by %1 Device Manager"
		qsTrId("settings_system-la-disabled_by_device_manager")
                    .arg(aboutSettings.baseOperatingSystemName)
            } else {
                //: %1 is operating system name without OS suffix
                //% "Changes limited by %1 Device Manager"
		qsTrId("settings_system-la-limited_by_device_manager")
                    .arg(aboutSettings.baseOperatingSystemName)
            }
        }
        color: Theme.highlightColor
    }

    AboutSettings {
        id: aboutSettings
    }
}
