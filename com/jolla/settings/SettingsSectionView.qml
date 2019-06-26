import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.settings 1.0
import org.nemomobile.configuration 1.0

Column {
    id: root

    property string name
    property string entryPath
    property int depth: 1
    property string iconSource
    property int columns: Screen.sizeCategory >= Screen.Large ? 2 : 1
    property real itemWidth: width / columns

    SectionHeader {
        text: name
    }

    Flow {
        width: parent.width

        Repeater {
            id: repeater

            model: SettingsModel {
                path: root.entryPath.split("/")
                depth: root.depth
            }

            delegate: SettingComponentLoader {
                width: itemWidth
                settingsObject: model.object
                onLoaded: {
                    if (columns === 2) {
                        if (item.hasOwnProperty("leftMargin")) {
                            item.leftMargin = Qt.binding(function() { return model.index % 2 ? Theme.paddingMedium : Theme.horizontalPageMargin })
                        }
                        if (item.hasOwnProperty("rightMargin")) {
                            item.rightMargin = Qt.binding(function() { return model.index % 2 ? Theme.horizontalPageMargin : Theme.paddingMedium })
                        }
                    }
                }
            }
        }
    }
}
