// -*- qml -*-

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.theme 1.0
import com.jolla.mediaplayer 1.0

ListItem {
    id: item

    property alias icon: albumArt.source
    property string title
    property alias titleFont: titleLabel.font
    property alias subtitle: subtitleLabel.text
    property alias subtitleFont: subtitleLabel.font
    property var formatFilter

    contentHeight: Theme.itemSizeExtraLarge

    AlbumArt {
        id: albumArt
        highlighted: item.highlighted
    }

    Column {
        id: column

        anchors {
            left: albumArt.right
            leftMargin: Theme.paddingLarge
            right: parent.right
            rightMargin: Theme.paddingMedium
            verticalCenter: albumArt.verticalCenter
        }

        Label {
            id: titleLabel
            width: parent.width
            font.family: Theme.fontFamilyHeading
            font.pixelSize: Theme.fontSizeMedium
            text: Theme.highlightText(item.title, RegExpHelpers.regExpFromSearchString(formatFilter, false), Theme.highlightColor)
            color: highlighted ? Theme.highlightColor : Theme.primaryColor
            truncationMode: TruncationMode.Fade
        }

        Label {
            id: subtitleLabel
            width: parent.width
            font.family: Theme.fontFamilyHeading
            font.pixelSize: Theme.fontSizeSmall
            color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
            truncationMode: TruncationMode.Fade
        }
    }
}
