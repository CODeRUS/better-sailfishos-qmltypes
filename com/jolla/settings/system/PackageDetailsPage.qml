import QtQuick 2.6
import Sailfish.Silica 1.0
import com.jolla.settings.system 1.0

Page {
    id: root

    property alias title: header.title
    property alias description: descriptionLabel.text
    property alias version: versionDetail.value
    property alias license: licenseDetail.value
    property alias files: filesList.text
    property alias licenseText: licenseTextLabel.text

    highContrast: true

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: content.height + Theme.paddingLarge

        Column {
            id: content
            width: parent.width

            PageHeader {
                id: header
            }

            Label {
                id: descriptionLabel
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * x
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.highlightColor
            }

            DetailItem {
                id: versionDetail
                //% "Version"
                label: qsTrId("settings_package_licenses-la-package_version")
                alignment: Qt.AlignLeft
            }

            DetailItem {
                id: licenseDetail
                //% "License"
                label: qsTrId("settings_package_licenses-la-package_license")
                alignment: Qt.AlignLeft
            }

            SectionHeader {
                //% "Files"
                text: qsTrId("settings_package_licenses-la-package_files")
                visible: filesList.text
            }

            SilicaFlickable {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * x
                height: filesList.height
                contentHeight: height
                contentWidth: filesList.width
                flickableDirection: Flickable.HorizontalFlick
                clip: true

                Label {
                    id: filesList
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.secondaryHighlightColor
                }
            }

            SectionHeader {
                //% "License text"
                text: qsTrId("settings_package_licenses-la-package_license_text")
                visible: root.licenseText
            }

            Label {
                id: licenseTextLabel
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * x
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryHighlightColor
            }

            VerticalScrollDecorator {}
        }
    }
}
