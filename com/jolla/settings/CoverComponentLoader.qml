import QtQuick 2.0
import com.jolla.settings 1.0

Loader {
    id: root

    property variant settingsObject

    source: {
        var objType = settingsObject.type

        if (objType === "bool") {
            return "CoverSwitchSetting.qml"
        } else if (objType === "custom") {
            // notice custom QML screens will not use SettingsItem
            // so will not have entryPath properties etc.
            var params = settingsObject.data()["params"]
            if (params) {
                return params.cover_source
            }
        }
        return ""
    }

    onLoaded: {
        var objType = settingsObject.type
        var params = settingsObject.data()["params"]

        if (item.hasOwnProperty("entryPath") && item.entryPath === "") {
            item.entryPath = settingsObject.location().join("/")
        }

        if (objType === "bool") {
            item.iconSource = settingsObject.icon ? settingsObject.icon : ""
            if (params) {
                item.saveKey = params.key ? params.key : ""
                item.defaultSaveValue = params.defaultValue ? params.defaultValue : false
            }
        }
    }
}

