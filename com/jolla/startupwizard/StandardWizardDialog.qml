import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.theme 1.0

Dialog {
    id: root

    property alias dialogTitle: dialogHeader.title

    property alias heading: headingLabel.text
    property alias description: descriptionLabel.text
    property alias columnContent: contentColumn.data

    default property alias _defaultContent: root.data

    DialogHeader {
        id: dialogHeader
        dialog: root
    }

    Column {
        id: contentColumn
        anchors.top: dialogHeader.bottom
        width: parent.width

        Label {
            id: headingLabel
            x: Theme.paddingLarge
            width: parent.width - x*2
            height: implicitHeight + Theme.paddingLarge
            wrapMode: Text.WordWrap
            font {
                family: Theme.fontFamilyHeading
                pixelSize: Theme.fontSizeExtraLarge
            }
            color: Theme.highlightColor
        }

        Label {
            id: descriptionLabel
            x: Theme.paddingLarge
            width: parent.width - x*2
            height: implicitHeight + Theme.paddingLarge
            wrapMode: Text.WordWrap
            font.pixelSize: Theme.fontSizeExtraSmall
            color: Theme.rgba(Theme.highlightColor, 0.9)
        }
    }
}
