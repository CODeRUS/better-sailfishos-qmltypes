import QtQuick 2.0
import Sailfish.Silica 1.0
import QtDocGallery 5.0
import "private"

Page {
    id: detailsPage
    property alias modelItem: galleryItem.item

    allowedOrientations: Orientation.All

    DocumentGalleryItem {
        id: galleryItem
        autoUpdate: false
        properties: [ 'fileName', 'fileSize', 'mimeType', 'width', 'height', 'duration', 
                      'dateTaken', 'cameraManufacturer', 'cameraModel', 'exposureTime',
                      'fNumber', 'focalLength' ]

        onStatusChanged: {
            if (status == DocumentGalleryItem.Finished) {
                nameItem.value = galleryItem.metaData.fileName
                sizeItem.value = Format.formatFileSize(galleryItem.metaData.fileSize)
                typeItem.value = galleryItem.metaData.mimeType
                widthItem.value = galleryItem.metaData.width
                heightItem.value = galleryItem.metaData.height

                if (itemType == DocumentGallery.Image) {
                    dateTakenItem.value = galleryItem.metaData.dateTaken != ""
                            ? Format.formatDate(galleryItem.metaData.dateTaken, Format.Timepoint)
                             : ""
                    cameraManufacturerItem.value = galleryItem.metaData.cameraManufacturer
                    cameraModelItem.value = galleryItem.metaData.cameraModel
                    exposureTimeItem.value = galleryItem.metaData.exposureTime
                    fNumberItem.value = galleryItem.metaData.fNumber != ""
                            //: Camera aperture value
                            //% "f/%1"
                            ? qsTrId("gallery-value-fnumber").arg(galleryItem.metaData.fNumber) : ""
                    focalLengthItem.value = galleryItem.metaData.focalLength != ""
                            //: Camera focal length in millimeters
                            //% "%1 mm"
                            ? qsTrId("gallery-value-focal-length").arg(galleryItem.metaData.focalLength) : ""
                }

                if (itemType == DocumentGallery.Video) {
                    durationItem.value = Format.formatDuration(galleryItem.metaData.duration, Formatter.DurationLong)
                }
            }
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column

            width: parent.width

            PageHeader {
                //: This is a temporary translation ID to re-use translations from jolla-gallery.  The ID should be corrected before translation.
                //% "Details"
                title: qsTrId("gallery-he-details")
            }
            DetailItem {
                id: nameItem
                //% "Filename"
                label: qsTrId("gallery-la-filename")
            }
            DetailItem {
                id: sizeItem
                //% "Size"
                label: qsTrId("gallery-la-size")
            }
            DetailItem {
                id: typeItem
                //% "Type"
                label: qsTrId("gallery-la-type")
            }
            DetailItem {
                id: widthItem
                //% "Width"
                label: qsTrId("gallery-la-width")
            }
            DetailItem {
                id: heightItem
                //% "Height"
                label: qsTrId("gallery-la-height")
            }
            DetailItem {
                id: dateTakenItem
                //% "Date Taken"
                label: qsTrId("gallery-la-date-taken")
                visible: value.length > 0
            }
            DetailItem {
                id: cameraManufacturerItem
                //% "Camera Manufacturer"
                label: qsTrId("gallery-la-camera-manufacturer")
                visible: value.length > 0
            }
            DetailItem {
                id: cameraModelItem
                //% "Camera Model"
                label: qsTrId("gallery-la-camera-model")
                visible: value.length > 0
            }
            DetailItem {
                id: exposureTimeItem
                //% "Exposure Time"
                label: qsTrId("gallery-la-exposure-time")
                visible: value.length > 0
            }
            DetailItem {
                id: fNumberItem
                //% "Aperture"
                label: qsTrId("gallery-la-aperture")
                visible: value.length > 0
            }
            DetailItem {
                id: focalLengthItem
                //% "Focal Length"
                label: qsTrId("gallery-la-focal-length")
                visible: value.length > 0
            }
            DetailItem {
                id: durationItem
                //% "Duration"
                label: qsTrId("gallery-la-duration")
                visible: value.length > 0
            }
        }
        VerticalScrollDecorator { }
    }
}
