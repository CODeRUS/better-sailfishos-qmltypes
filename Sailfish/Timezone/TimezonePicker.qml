import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.theme 1.0
import Sailfish.Timezone 1.0

Page {
    id: page

    signal timezoneClicked(variant name)

    SilicaListView {
        id: view

        anchors.fill: parent
        currentIndex: -1
        focus: true
        model: TimezoneModel { }
        header: Column {
            width: view.width

            PageHeader {
                //% "Time zone"
                title: qsTrId("components_timezone-he-time_zone")
            }

            SearchField {
                id: searchField
                width: view.width
                focus: true
                Binding {
                    target: view.model
                    property: "filter"
                    value: searchField.text.toLowerCase().trim()
                }
            }

            Connections {
                target: searchField.activeFocus ? view : null
                ignoreUnknownSignals: true
                onContentYChanged: {
                    if (view.contentY > (Screen.height / 2)) {
                        searchField.focus = false
                    }
                }
            }
        }
        delegate: BackgroundItem {
            id: background
            property bool highlight: background.down || view.model.timezone == model.name
            height: Theme.itemSizeMedium
            onClicked: page.timezoneClicked(model.name)
            Label {
                id: countryLabel
                anchors {
                    left: parent.left
                    leftMargin: Theme.paddingLarge
                    verticalCenter: parent.verticalCenter
                    verticalCenterOffset: -subLabel.implicitHeight / 2
                }
                textFormat: Text.StyledText
                text: Theme.highlightText(model.country, view.model.filter, Theme.highlightColor)
                color: background.highlight ? Theme.highlightColor : Theme.primaryColor
            }
            Label {
                id: subLabel
                anchors {
                    left: parent.left
                    leftMargin: Theme.paddingLarge
                    top: countryLabel.bottom
                }
                text: model.offsetWithDstOffset + " " + Theme.highlightText(model.city, view.model.filter, Theme.highlightColor)
                font.pixelSize: Theme.fontSizeSmall
                color: background.highlight ? Theme.highlightColor : Theme.secondaryColor
            }
        }
        section.property: "sectionOffset"
        section.delegate: SectionHeader {
            height: Theme.itemSizeExtraSmall
            text: section
        }

        VerticalScrollDecorator {}
    }
}
