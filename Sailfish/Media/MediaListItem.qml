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
        opacity: highlighted || playing ? 1.0 : 0.4
        horizontalAlignment: Text.AlignRight
        font {
            family: Theme.fontFamilyHeading
            pixelSize: Theme.fontSizeExtraLarge
        }
        color: highlighted || playing ? Theme.highlightColor : Theme.primaryColor
        width: Theme.itemSizeExtraLarge - Theme.paddingMedium
        fontSizeMode: Text.HorizontalFit
    }

    Column {
        id: column
        anchors {
            left: durationLabel.right; leftMargin: Theme.paddingMedium
            top: parent.top; topMargin: Theme.paddingSmall
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
            horizontalAlignment: Text.AlignLeft
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
            horizontalAlignment: Text.AlignLeft
            textFormat: titleLabel.textFormat
            opacity: 0.6
            color: highlighted || playing ? Theme.highlightColor : Theme.primaryColor
            maximumLineCount: 1
        }
    }

    // TODO: Remove this and change above labels to use truncationMode: TruncationMode.Fade
    // once bug #8173 is fixed.
    OpacityRampEffect {
        slope: 1 + 6 * column.width / Screen.width
        offset: 1 - 1 / slope
        sourceItem: column
        enabled: titleLabel.implicitWidth > Math.ceil(titleLabel.width) ||
                 subtitleLabel.implicitWidth > Math.ceil(subtitleLabel.width)
    }
}
