import QtQuick 2.0
import com.jolla.settings 1.0

Loader {
    id: root

    property variant settingsObject
    property bool gridMode

    signal contextMenuRequested(string settingEntryPath)

    width: parent.width
//    height: item && item.height > 0 ? item.height : 50

    source: {
        var objType = settingsObject.type

        if (objType === "bool") {
            return "SwitchSetting.qml"
        } else if (objType === "integer") {
            return "SliderSetting.qml"
        } else if (objType === "section") {
            return "SettingsSectionLink.qml"
        } else if (objType === "page") {
            if (gridMode) {
                return "SettingsPageLinkGrid.qml"
            } else {
                return "SettingsPageLink.qml"
            }
        } else if (objType === "custom") {
            // notice custom QML screens will not use SettingsItem
            // so will not have entryPath properties etc.
            var params = settingsObject.data()["params"]
            if (params) {
                return params.source
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
        } else if (objType === "integer") {
            // todo currently the slider will animate to its position.
            // We can fix this either by backporting Loader.createObject()
            // or by using Component.createObject() with initial property
            // values and use a root Item instead of a Loader.
            if (params) {
                item.saveKey = params.key ? params.key : ""
                item.defaultSaveValue = params.defaultValue ? params.defaultValue : 0
                if (params.min)
                    item.minimumValue = parseInt(params.min)
                if (params.max)
                    item.maximumValue = parseInt(params.max)
            }
        } else if (objType === "section") {
            item.name = settingsObject.title
            item.iconSource = settingsObject.icon ? settingsObject.icon : ""
            if (params) {
                item.depth = params.depth && params.depth > 0 ? params.depth : 1
            }
        } else if (objType === "page") {
            // Special handling for applications/something.desktop. Get icon used in the desktop file.
            var location = settingsObject.location()
            if (location[0] === "applications" && location.length === 2) {
                var icon = ApplicationsModel.iconOf(location[1])
                item.iconSource = (icon.indexOf("/") === 0 ? "file://" : "image://theme/") + icon
                item.useHighlightColor = false
            } else {
                item.iconSource = settingsObject.icon ? settingsObject.icon : ""
            }

            item.name = settingsObject.title
            if (params) {
                item.pageSource = params.source ? params.source : ""
            }
        }
    }

    Connections {
        target: item
        ignoreUnknownSignals: true
        onPressAndHold: root.contextMenuRequested(item.entryPath)
    }
}

