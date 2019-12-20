import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.DBus 2.0
import com.jolla.settings 1.0 // Load translations

SettingsControl {
    id: root

    // Whether the switch is "available" for changing state. Can be unavailable e.g. due to flight mode.
    // Mouse events are passed through.
    property bool available: true

    // Whether the switch is in the "checked" state.
    property bool checked

    // Whether the setting is "active". While "checked" indicates when a setting is "on", "active"
    // indicates some additional state; for example, when a connection has been established.
    property bool active

    // Whether the switch is in a "busy" state and should not be enabled.
    property bool busy

    // Whether the switch shows on/off label on click
    property bool showOnOffLabel: true

    // The text to be displayed when active=true.
    property string activeText: name

    // The setting icon image.
    property alias icon: dummyImage

    property string systemIcon: entryParams["system_icon"] || "image://theme/icon-system-resources"

    property alias errorNotification: errorNotification

    readonly property bool _effectiveHighlight: checked || active || highlighted
    readonly property bool _showOnOffLabel: onOffLabelTimer.running || busy
    // Postpone icon change until _showOnOffLabel has changed.
    on_ShowOnOffLabelChanged: if (!_showOnOffLabel) iconImage.source = dummyImage.source

    property int __jolla_settings_toggle

    // Emitted when the "checked" state should be toggled.
    // Note: Use this instead of onClicked, to ensure user access restrictions are correctly filtered.
    signal toggled()

    width: implicitWidth
    contentHeight: label.y + label.height + Theme.paddingSmall
    settingsPageEntryPath: entryParams["settings_path"] || ""
    _showPress: false

    onClicked: {
        if (busy) {
            errorNotification.notify(SettingsControlError.InProgress)
            return
        }
        if (userAccessRestricted) {
            requestUserAccess()
        } else {
            if (available && showOnOffLabel) {
                onOffLabel.text = checked
                        //: Shown when the setting is turned off
                        //% "Off"
                        ? qsTrId("settings-la-setting_off")
                        //: Shown when the setting is turned on
                        //% "On"
                        : qsTrId("settings-la-setting_on")
                onOffLabelTimer.restart()
            }
            toggled()
        }
    }

    Rectangle {
        id: circle

        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
            topMargin: Theme.paddingSmall
        }
        width: Theme.itemSizeSmall
        height: Theme.itemSizeSmall
        radius: width/2

        opacity: root.checked ? (root.highlighted ? Theme.opacityHigh : Theme.opacityLow) : (root.available ? Theme.opacityFaint : 0.05)
        color: _effectiveHighlight ? Theme.highlightColor : Theme.primaryColor
    }

    Image {
        id: dummyImage
        visible: false

        onSourceChanged: if (!_showOnOffLabel) iconImage.source = source
        Component.onCompleted: iconImage.source = source
    }

    HighlightImage {
        id: iconImage

        anchors.centerIn: circle
        opacity: root._showOnOffLabel ? 0 : (root.available ? 1.0 : Theme.opacityLow)
        highlighted: _effectiveHighlight
        width: dummyImage.width
        height: dummyImage.height
        sourceSize.width: dummyImage.sourceSize.width
        sourceSize.height: dummyImage.sourceSize.height

        Behavior on opacity { FadeAnimator { duration: 100 } }
    }

    Label {
        id: onOffLabel

        anchors.centerIn: circle
        width: circle.width - Theme.paddingSmall
        horizontalAlignment: Text.AlignHCenter
        opacity: root._showOnOffLabel ? 1 : 0
        color: _effectiveHighlight ? Theme.highlightColor : Theme.primaryColor
        font.pixelSize: Theme.fontSizeTiny
        fontSizeMode: Text.HorizontalFit

        Behavior on opacity { FadeAnimator { duration: 100 } }
    }

    Label {
        id: label

        anchors {
            horizontalCenter: parent.horizontalCenter
            top: circle.bottom
            topMargin: Theme.paddingSmall
        }
        width: root.width - Theme.paddingMedium*2
        horizontalAlignment: implicitWidth > width ? Text.AlignLeft : Text.AlignHCenter
        truncationMode: TruncationMode.Fade

        text: (root.active && root.activeText.length > 0 && !root._showOnOffLabel) ? root.activeText : root.name
        font.pixelSize: Theme.fontSizeTiny
        color: circle.color
    }

    Timer {
        id: onOffLabelTimer

        interval: 1500
    }

    SettingsErrorNotification {
        id: errorNotification
    }
}
