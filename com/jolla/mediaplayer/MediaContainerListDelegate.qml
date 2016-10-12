// -*- qml -*-

import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.mediaplayer 1.0

ListItem {
    id: item

    property string title
    property alias titleFont: titleLabel.font
    property alias subtitle: subtitleLabel.text
    property alias subtitleFont: subtitleLabel.font
    property var formatFilter
    property real leftPadding: Theme.horizontalPageMargin

    contentHeight: Theme.itemSizeSmall

    Column {
        id: column

        anchors {
            left: parent.left
            leftMargin: item.leftPadding
            right: parent.right
            rightMargin: Theme.horizontalPageMargin
            verticalCenter: parent.verticalCenter
        }

        Label {
            id: titleLabel
            width: parent.width
            font.family: Theme.fontFamilyHeading
            font.pixelSize: Theme.fontSizeMedium
            text: Theme.highlightText(item.title, RegExpHelpers.regExpFromSearchString(formatFilter, false), Theme.highlightColor)
            textFormat: Text.StyledText
            color: highlighted ? Theme.highlightColor : Theme.primaryColor
            truncationMode: TruncationMode.Fade
        }

        Label {
            id: subtitleLabel
            visible: text != ""
            width: parent.width
            font.family: Theme.fontFamilyHeading
            font.pixelSize: Theme.fontSizeExtraSmall
            color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
            truncationMode: TruncationMode.Fade
        }
    }
}
