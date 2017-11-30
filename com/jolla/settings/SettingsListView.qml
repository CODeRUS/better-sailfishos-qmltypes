import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.settings 1.0
import org.nemomobile.configuration 1.0

FocusScope {
    id: root
    property string name
    property string entryPath
    property url iconSource
    property int depth: 1
    property alias header: listView.header
    property alias section: listView.section

    width: parent.width
    implicitHeight: listView.contentHeight + Theme.paddingLarge

    SilicaListView {
        id: listView

        focus: true
        height: Screen.height * 1000
        width: parent.width

        model: SettingsModel {
            path: root.entryPath.split("/")
            depth: root.depth
        }

        delegate: SettingComponentLoader {
            settingsObject: model.object
            sectionSource: "SettingsSectionView.qml"
        }
    }
}
