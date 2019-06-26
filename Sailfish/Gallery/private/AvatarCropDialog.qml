import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Gallery 1.0
import Sailfish.Gallery.private 1.0

ImageEditDialog {
    cropOnly: true
    aspectRatio: 1.0
    aspectRatioType: "avatar"

    //% "Crop avatar"
    title: qsTrId("sailfish-components-gallery-he-crop_avatar")
}
