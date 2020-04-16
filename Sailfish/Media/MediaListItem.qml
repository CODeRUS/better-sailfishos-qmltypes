// -*- qml -*-

import QtQuick 2.0
import Sailfish.Silica 1.0

ListItem {
    id: mediaListItem

    property variant duration
    property string title
    property string subtitle
    property alias textFormat: titleLabel.textFormat
    property alias subtitleTextFormat: subtitleLabel.textFormat
    property bool playing

    contentHeight: Math.max(Theme.itemSizeMedium, column.height + 2 * Theme.paddingMedium)

    Label {
        id: durationLabel
        x: Theme.horizontalPageMargin
        text: {
            if (mediaListItem.duration === undefined) {
                return ""
            } else if (typeof mediaListItem.duration == "string") {
                return mediaListItem.duration
            } else {
                return Format.formatDuration(mediaListItem.duration, mediaListItem.duration >= 3600
                        ? Format.DurationLong
                        : Format.DurationShort)
            }
        }
        opacity: highlighted || playing ? 1.0 : Theme.opacityLow
        horizontalAlignment: Text.AlignRight
        font {
            family: Theme.fontFamilyHeading
            pixelSize: Theme.fontSizeExtraLarge
        }
        anchors {
            top: column.top
            topMargin: -Theme.paddingSmall
        }

        color: highlighted || playing ? Theme.highlightColor : Theme.primaryColor
        width: Theme.itemSizeExtraLarge - Theme.paddingMedium
        fontSizeMode: Text.HorizontalFit
    }

    Column {
        id: column

        anchors {
            left: durationLabel.right; leftMargin: Theme.paddingMedium
            verticalCenter: parent.verticalCenter
            right: parent.right; rightMargin: Theme.horizontalPageMargin
        }
        Label {
            id: titleLabel
            width: parent.width
            text: mediaListItem.title
            font {
                family: Theme.fontFamilyHeading
                pixelSize: Theme.fontSizeMedium
            }
            truncationMode: TruncationMode.Fade
            textFormat: Text.AutoText
            color: highlighted || playing ? Theme.highlightColor : Theme.primaryColor
            maximumLineCount: 1
        }

        Label {
            id: subtitleLabel
            width: parent.width
            text: mediaListItem.subtitle
            font {
                family: Theme.fontFamily
                pixelSize: Theme.fontSizeExtraSmall
            }
            truncationMode: TruncationMode.Fade
            textFormat: titleLabel.textFormat
            color: highlighted || playing ? Theme.secondaryHighlightColor : Theme.secondaryColor
            maximumLineCount: 1
        }
    }
}
