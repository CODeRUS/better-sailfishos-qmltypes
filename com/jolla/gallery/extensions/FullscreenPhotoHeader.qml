import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.social 1.0
import org.nemomobile.socialcache 1.0
import com.jolla.gallery.extensions 1.0

Item {
    id: root

    property alias photoName: nameLabel.photoName
    property string dateTime

    property real _margin: pageStack.currentPage.isLandscape ? Theme.paddingLarge : Theme.horizontalPageMargin

    width: parent.width
    height: headerColumn.height

    Column {
        id: headerColumn
        spacing: Theme.paddingSmall
        width: parent.width

        Item {
            width: 1
            height: Theme.paddingLarge
        }

        Label {
            id: nameLabel
            //% "No title"
            property string unknownNameStr: qsTrId("jolla_gallery_extensions-la-unnamed_photo")
            property string photoName
            text: photoName == "" ? unknownNameStr : photoName
            width: parent.width - _margin
            elide: Text.ElideRight
            anchors {
                right: parent.right
                rightMargin: _margin
            }
            font.pixelSize: Theme.fontSizeLarge
            color: Theme.highlightColor
            horizontalAlignment: Text.AlignRight
            maximumLineCount: 1
        }

        Label {
            id: dateTimeLabel
            text: Format.formatDate(root.dateTime, Format.DateLong)
            color: Theme.highlightColor
            font.pixelSize: Theme.fontSizeExtraSmall
            opacity: .6
            anchors {
                right: parent.right
                rightMargin: _margin
            }
        }

        Item {
            width: 1
            height: Theme.paddingLarge
        }
    }
}
