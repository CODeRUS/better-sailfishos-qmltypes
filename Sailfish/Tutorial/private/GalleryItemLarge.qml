import QtQuick 2.0
import Sailfish.Silica 1.0

BackgroundItem {
    id: delegateItem

    property int count
    property string thumbnail
    property alias title: titleLabel.text

    highlightedColor: Theme.rgba(tutorialTheme.highlightColor, 0.3)

    width: parent.width
    height: row.height

    Row {
        id: row

        anchors {
            right: parent.right
            rightMargin: 4*Theme.paddingLarge
        }
        height: thumb.height
        spacing: 2*Theme.paddingLarge

        Column {
            Label {
                id: titleLabel

                anchors.right: parent.right
                font.pixelSize: Theme.fontSizeLarge
                color: delegateItem.down ? tutorialTheme.highlightColor : tutorialTheme.primaryColor
            }

            Label {
                anchors.right: parent.right

                color: delegateItem.down ? tutorialTheme.highlightColor : tutorialTheme.primaryColor

                text: thumbnail === "videos"
                      //% "%n videos"
                      ? qsTrId("tutorial-la-gallery_videos_count", count).arg(count)
                      //% "%n photos"
                      : qsTrId("tutorial-la-gallery_photos_count", count).arg(count)
            }
        }

        Image {
            id: thumb

            opacity: delegateItem.down ? 0.5 : 1
            source: Screen.sizeCategory >= Screen.Large
                    ? Qt.resolvedUrl("file:///usr/share/sailfish-tutorial/graphics/tutorial-tablet-gallery-thumb-" + thumbnail + ".png")
                    : Qt.resolvedUrl("file:///usr/share/sailfish-tutorial/graphics/tutorial-phone-gallery-thumb-" + thumbnail + ".png")
        }
    }
}

