import QtQuick 2.0
import Sailfish.Silica 1.0

ThumbnailBase {

    property url thumbnailSource

    Loader {
        y: contentYOffset
        x: contentXOffset
        width: size
        height: size
        source: thumbnailSource
    }
}
