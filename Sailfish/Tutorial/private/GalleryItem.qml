import QtQuick 2.0
import Sailfish.Silica 1.0

BackgroundItem {
    id: delegateItem

    property int count
    property string thumbnail
    property alias title: titleLabel.text

    width: parent.width
    height: (Screen.sizeCategory >= Screen.Large ? 275 : 123) * yScale

    Label {
        anchors {
            right: thumb.left
            rightMargin: Theme.paddingLarge
            verticalCenter: parent.verticalCenter
        }
        opacity: 0.4
        text: count
        color: delegateItem.down ? tutorialTheme.highlightColor : tutorialTheme.primaryColor
        font.pixelSize: Theme.fontSizeLarge
    }

    Image {
        id: thumb
        x: Theme.itemSizeExtraLarge + Theme.horizontalPageMargin - Theme.paddingLarge
        width: parent.height
        height: parent.height
        opacity: delegateItem.down ? 0.5 : 1
        source: Screen.sizeCategory >= Screen.Large
                ? Qt.resolvedUrl("file:///usr/share/sailfish-tutorial/graphics/tutorial-tablet-gallery-thumb-" + thumbnail + ".png")
                : Qt.resolvedUrl("file:///usr/share/sailfish-tutorial/graphics/tutorial-phone-gallery-thumb-" + thumbnail + ".png")
    }

    Label {
        id: titleLabel
        elide: Text.ElideRight
        font.pixelSize: Theme.fontSizeLarge
        color: delegateItem.down ? tutorialTheme.highlightColor : tutorialTheme.primaryColor
        anchors {
            left: thumb.right
            right: parent.right
            leftMargin: Theme.paddingLarge
            rightMargin: Theme.horizontalPageMargin
            verticalCenter: parent.verticalCenter
        }
    }
}
