import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.settings 1.0

SilicaListView {
    id: root

    function moveToSection(path) {
        var array = path.split("/")
        if (array.length > 0) {
            var section = array[0]
            for (var i = 0; i < model.count; ++i) {
                if (model.objectAt(i).name === section) {
                    positionViewAtIndex(i, ListView.Beginning)
                    return
                }
            }

            console.warn("moveToSection(", section, ") - not found")
        }
    }

    property string name
    property string entryPath
    property url iconSource
    property int depth: 1

    width: parent.width
    height: parent.height

    model: SettingsModel {
        path: root.entryPath.split("/")
        depth: root.depth
    }

    delegate: SettingComponentLoader {
        settingsObject: model.object
        sectionSource: "SettingsSectionView.qml"
    }

    footer: Item {
        width: 1
        height: Theme.paddingLarge
    }

    VerticalScrollDecorator {}
}
