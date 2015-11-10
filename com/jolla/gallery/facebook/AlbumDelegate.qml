import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.theme 1.0
import org.nemomobile.socialcache 1.0

BackgroundItem {
    id: root

    property string albumName
    property string albumIdentifier
    property string userIdentifier
    property FacebookImageCacheModel imagesModel: FacebookImageCacheModel {
        function nodeIdentifierValue() {
            if (root.albumIdentifier == "" && root.userIdentifier == "") {
                return ""
            } else if (root.albumIdentifier == "" && root.userIdentifier != "") {
                return "user-" + root.userIdentifier
            } else {
                return "album-" + root.albumIdentifier
            }
        }

        Component.onCompleted: refresh()
        type: FacebookImageCacheModel.Images
        nodeIdentifier: nodeIdentifierValue()
        downloader: FacebookImageDownloader
    }

    height: Theme.itemSizeExtraLarge

    SlideshowIcon {
        id: image
        // Between 7 and 14 s, it is funnier when it is random
        timerInterval: 7000 +  Math.floor((Math.random() * 7000));
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

            //: Photos count for facebook album
            //% "%n photos"
            text: qsTrId("jolla_gallery_facebook-album_photo_count", dataCount)
            font.family: Theme.fontFamilyHeading
            font.pixelSize: Theme.fontSizeSmall
            color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
            truncationMode: TruncationMode.Fade
        }
    }
}
