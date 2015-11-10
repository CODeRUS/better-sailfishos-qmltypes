import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.settings 1.0
import org.nemomobile.configuration 1.0

Page {
    id: page

    property alias name: listView.name
    property alias entryPath: listView.entryPath
    property alias depth: listView.depth

    SettingsListView {
        id: listView

        anchors.fill: parent

        header: PageHeader {
            title: page.name
        }

        section.property: page.depth > 1 ? "category" : ""
        section.criteria: ViewSection.FullString
        section.delegate: SectionHeader { text: section }

        VerticalScrollDecorator {}
    }
}
