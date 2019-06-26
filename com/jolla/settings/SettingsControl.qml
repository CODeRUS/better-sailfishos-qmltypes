import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.DBus 2.0
import com.jolla.settings 1.0   // Load translations

ListItem {
    id: root

    // For SettingsComponentLoader: the path in the settings entries that identifies this setting.
    property string entryPath

    // For SettingsComponentLoader: the "params" map in the settings entries for setting.
    property var entryParams: ({})

    // The path in the settings entries that points to the settings page relevant to this control.
    // E.g. system_settings/connectivity/bluetooth for Bluetooth settings.
    property string settingsPageEntryPath

    // The setting name.
    property string name

    // A shorter name for the setting, if available.
    property string shortName

    // True if user access is restricted (i.e. this switch requires privileged access and the
    // device is locked) so user interaction should be limited accordingly.
    property bool userAccessRestricted

    property bool privileged: entryParams.privileged === "true"

    // A control can emit this to request that user access restrictions be lifted.
    signal requestUserAccess()


    function goToSettings(settingsPath) {
        var path = settingsPath || settingsPageEntryPath
        if (path != "") {
            settingsApp.call('showPage', [path])
        }
    }

    width: Screen.width
    menu: settingsPageEntryPath.length > 0 ? menuComponent : null
    _showPress: false

    // Add empty handler to prevent this action from triggering onClicked.
    onPressAndHold: { }

    Component {
        id: menuComponent

        ContextMenu {
            SettingsMenuItem {
                onClicked: root.goToSettings()
            }
        }
    }

    DBusInterface {
        id: settingsApp

        service: "com.jolla.settings"
        path: "/com/jolla/settings/ui"
        iface: "com.jolla.settings.ui"
    }
}
