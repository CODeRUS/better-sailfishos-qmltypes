import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.thumbnailer 1.0

ThumbnailBase {
    id: thumbnailBase

    Thumbnail {
        id: thumbnail
        property bool gridMoving: thumbnailBase.grid ? thumbnailBase.grid.moving : false

        source: thumbnailBase.source
        mimeType: thumbnailBase.mimeType
        width:  size
        height: size
        sourceSize.width: width
        sourceSize.height: height
        y: contentYOffset
        x: contentXOffset
        priority: Thumbnail.NormalPriority

        onGridMovingChanged: {
            if (!gridMoving) {
                var visibleIndex = Math.floor(thumbnailBase.grid.contentY / size) * thumbnailBase.grid.columnCount

                if (visibleIndex <= index && index <= visibleIndex + 18) {
                    priority = Thumbnail.HighPriority
                } else {
                    priority = Thumbnail.LowPriority
                }
            }
        }

        onStatusChanged: {
            if (status == Thumbnail.Error) {
                errorLabelComponent.createObject(thumbnail)
            }
        }
    }

    Component {
        id: errorLabelComponent
        Label {
            //: Thumbnail Image loading failed
            //% "Oops, can't display the thumbnail!"
            text: qsTrId("components_gallery-la-image-thumbnail-loading-failed")
            anchors.centerIn: parent
            width: parent.width - 2 * Theme.paddingMedium
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: Theme.fontSizeSmall
        }
    }
}
