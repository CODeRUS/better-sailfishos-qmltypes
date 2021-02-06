import QtQuick 2.6
import Sailfish.Silica 1.0
import com.jolla.settings.system 1.0

Page {
    highContrast: true

    BusyIndicator {
         size: BusyIndicatorSize.Large
         anchors.centerIn: parent
         running: !packageModel.modelLoaded
    }

    SilicaListView {
        anchors.fill: parent
        model: packageModel
        currentIndex: -1 // otherwise currentItem will steal focus

        header: Column {
            width: parent.width

            PageHeader {
                //% "Installed packages"
                title: qsTrId("settings_package_licenses-installed-packages")
            }
        }

        footer: Item {
            height: Theme.paddingMedium
        }

        delegate: BackgroundItem {
            height: Math.max(Theme.itemSizeSmall, nameLabel.height + licenseLabel.height + Theme.paddingMedium)

            Label {
                id: nameLabel
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * x
                color: highlighted ? Theme.highlightColor : Theme.primaryColor
                truncationMode: TruncationMode.Fade
                text: name
                textFormat: Text.StyledText
            }

            Label {
                id: licenseLabel
                anchors {
                    top: nameLabel.bottom
                    left: nameLabel.left
                }
                width: nameLabel.width
                color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                font.pixelSize: Theme.fontSizeSmall
                truncationMode: TruncationMode.Fade
                text: license
                textFormat: Text.StyledText
            }

            onClicked: {
                pageStack.animatorPush(Qt.resolvedUrl("PackageDetailsPage.qml"), {
                    title: name,
                    version: version,
                    description: description,
                    license: license,
                    licenseText: licenseText,
                    files: files
                })
            }
        }

        VerticalScrollDecorator {}
    }

    PackageModel {
        id: packageModel

        property bool modelLoaded
        onModelReset: modelLoaded = true
    }
}
