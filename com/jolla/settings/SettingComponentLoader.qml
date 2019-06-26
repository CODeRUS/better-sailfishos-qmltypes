import QtQuick 2.0
import com.jolla.settings 1.0

Loader {
    id: root

    property var settingsObject
    property url sectionSource: "SettingsSectionLink.qml"
    property url pageSource: "SettingsPageLink.qml"
    property url actionSource

    width: parent.width

    source: {
        var objType = settingsObject.type

        if (objType === "section") {
            return sectionSource
        } else if (objType === "page") {
            return pageSource
        } else if (objType === "action") {
            return actionSource
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
        if (item.hasOwnProperty("entryParams")) {
            item.entryParams = params
        }
        if (params && item.hasOwnProperty("depth")) {
            item.depth = params.depth && params.depth > 0 ? params.depth : 1
        }
        if (objType === "section" || objType === "action") {
            item.name = settingsObject.title
            if (item.hasOwnProperty("shortName")) {
                item.shortName = settingsObject.shortTitle
            }
            item.iconSource = settingsObject.icon ? settingsObject.icon : ""
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
            if (item.hasOwnProperty("shortName")) {
                item.shortName = settingsObject.shortTitle
            }
            if (params) {
                item.pageSource = params.source ? params.source : ""
            }
        }
    }
}

