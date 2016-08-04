import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.theme 1.0
import com.jolla.gallery.extensions 1.0

BackgroundItem {
    id: root

    property string albumName
    property string albumIdentifier
    property string userIdentifier
    property alias imagesModel: image.model
    property alias serviceIcon: image.serviceIcon

    height: Theme.itemSizeExtraLarge

    SlideshowIcon {
        id: image
        anchors.left: parent.left
        opacity: root.down ? 0.5 : 1
        model: root.imagesModel
    }

    Column {
        id: column

        anchors {
            left: image.right
            leftMargin: Theme.paddingLarge
            right: parent.right
            rightMargin: Theme.paddingMedium
            verticalCenter: image.verticalCenter
        }

        Label {
            id: titleLabel
            width: parent.width
            text: albumName
            font.family: Theme.fontFamilyHeading
            font.pixelSize: Theme.fontSizeMedium
            color: highlighted ? Theme.highlightColor : Theme.primaryColor
            truncationMode: TruncationMode.Fade
        }

        Label {
            id: subtitleLabel
            width: parent.width

            //: Photos count for Gallery album
            //% "%n photos"
            text: qsTrId("jolla_gallery_extensions-album_photo_count", dataCount)
            font.family: Theme.fontFamilyHeading
            font.pixelSize: Theme.fontSizeSmall
            color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
            truncationMode: TruncationMode.Fade
        }
    }
}
