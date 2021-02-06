import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0
import com.jolla.settings 1.0

TabItem {
    property var settingsObject
    readonly property string type: settingsObject ? settingsObject.type : ""

    function moveToSection(path) {
        if (loader.item && typeof loader.item.moveToSection == 'function') {
            loader.item.moveToSection(path)
        }
    }

    Loader {
        id: loader

        anchors.fill: parent
        sourceComponent: type === "section" ? sectionComponent : null
        source: {
            if (type === "view") {
                var params = settingsObject.data()["params"]
                if (params && params.source) {
                    return params.source
                }
            }
            return  ""
        }

        Component {
            id: sectionComponent
            SettingsListView {
                name: settingsObject.title
                entryPath: settingsObject.location().join("/")
            }
        }
    }
}
