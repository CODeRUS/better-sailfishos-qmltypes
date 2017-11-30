import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Lipstick 1.0
import com.jolla.settings 1.0

Page {
    id: page

    property string entryPath
    property int depth: 1
    property alias model: listView.model
    property string title

    function moveToSection(section) {
        for (var i = 0; i < listView.model.count; ++i) {
            if (listView.model.objectAt(i).name == section) {
                listView.positionViewAtIndex(i, ListView.Beginning)
                return
            }
        }

        console.warn("moveToSection(", section, ") - not found")
    }

    SilicaListView {
        id: listView

        focus: true
        anchors.fill: parent
        displayMarginBeginning: Screen.height * 1000
        displayMarginEnd: Screen.height * 1000

        header: PageHeader {
            title: page.title
        }

        model: SettingsModel {
            path: page.entryPath.length ? page.entryPath.split("/") : []
            depth: page.depth
        }

        delegate: SettingComponentLoader {
            settingsObject: model.object
            sectionSource: "SettingsListView.qml"
            pageSource: "SettingsFrontPageLink.qml"
            width: parent.width
        }

        VerticalScrollDecorator {}
    }
}
