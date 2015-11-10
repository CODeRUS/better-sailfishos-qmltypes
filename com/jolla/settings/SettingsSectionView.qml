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
    property real itemWidth: Screen.sizeCategory >= Screen.Large ? width/2 : width

    SectionHeader {
        text: name
    }

    Flow {
        width: parent.width
        Repeater {
            id: repeater

            width: parent.width

            model: SettingsModel {
                path: root.entryPath.split("/")
                depth: root.depth
            }

            delegate: Item {
                id: wrapper
                height: loaderObj.height
                width: itemWidth
                SettingComponentLoader {
                    id: loaderObj
                    settingsObject: model.object
                }
            }
        }
    }
}
