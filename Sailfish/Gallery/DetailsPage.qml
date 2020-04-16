import QtQuick 2.6
import Sailfish.Silica 1.0
import QtDocGallery 5.0
import "private"

Page {
    property alias modelItem: galleryItem.item

    allowedOrientations: Orientation.All

    // https://developer.gnome.org/ontology/stable/nmm-Flash.html
    property var flashValues: {
        'http://www.tracker-project.org/temp/nmm#flash-on':
        //% "Did fire"
        qsTrId("components_gallery-value-flash-on"),
        'http://www.tracker-project.org/temp/nmm#flash-off':
        //% "Did not fire"
        qsTrId("components_gallery-value-flash-off")
    }

    // https://developer.gnome.org/ontology/stable/nmm-MeteringMode.html
    property var meteringModeValues: {
        'http://www.tracker-project.org/temp/nmm#metering-mode-other':
        //% "Other"
        qsTrId("components_gallery-value-metering-mode-other"),
        'http://www.tracker-project.org/temp/nmm#metering-mode-partial':
        //% "Partial"
        qsTrId("components_gallery-value-metring-mode-partial"),
        'http://www.tracker-project.org/temp/nmm#metering-mode-pattern':
        //% "Pattern"
        qsTrId("components_gallery-value-metering-mode-pattern"),
        'http://www.tracker-project.org/temp/nmm#metering-mode-multispot':
        //% "Multispot"
        qsTrId("components_gallery-value-metering-mode-multispot"),
        'http://www.tracker-project.org/temp/nmm#metering-mode-spot':
        //% "Spot"
        qsTrId("components_gallery-value-metering-mode-spot"),
        'http://www.tracker-project.org/temp/nmm#metering-mode-center-weighted-average':
        //% "Center Weighted Average"
        qsTrId("components_gallery-value-metering-mode-center-weighted-average"),
        'http://www.tracker-project.org/temp/nmm#metering-mode-average':
        //% "Average"
        qsTrId("components_gallery-value-metering-mode-average")
    }

    // https://developer.gnome.org/ontology/stable/nmm-WhiteBalance.html
    property var whiteBalanceValues: {
        'http://www.tracker-project.org/temp/nmm#white-balance-manual':
        //% "Manual"
        qsTrId("components_gallery-value-white-balance-manual"),
        'http://www.tracker-project.org/temp/nmm#white-balance-auto':
        //% "Auto"
        qsTrId("components_gallery-value-white-balance-auto")
    }

    DocumentGalleryItem {
        id: galleryItem
        autoUpdate: false
        // See all properties at https://github.com/qtproject/qtdocgallery/blob/master/src/gallery/qdocumentgallery.h
        properties: [ 'filePath', 'fileSize', 'mimeType',
                      // Image & Video common
                      'width', 'height',
                      // Media
                      'duration',
                      // Photo
                      'dateTaken', 'cameraManufacturer', 'cameraModel',
                      // exposureProgram is not supported by Tracker thus not enabled.
                      // https://github.com/qtproject/qtdocgallery/blob/0b9ca223d4d5539ff09ce49a841fec4c24077830/src/gallery/qdocumentgallery.cpp#L799
                      'exposureTime',
                      'fNumber', 'flashEnabled', 'focalLength', 'meteringMode', 'whiteBalance',
                      'latitude', 'longitude', 'altitude',
                      'description', 'copyright', 'author'
                    ]

        onStatusChanged: {
            if (status == DocumentGalleryItem.Finished) {
                details.filePathDetail.value = galleryItem.metaData.filePath
                details.fileSizeDetail.value = Format.formatFileSize(galleryItem.metaData.fileSize)
                details.typeDetail.value = galleryItem.metaData.mimeType
                details.sizeDetail.value = details.formatDimensions(galleryItem.metaData.width, galleryItem.metaData.height)

                if (itemType == DocumentGallery.Image) {
                    details.dateTakenDetail.value = galleryItem.metaData.dateTaken != ""
                            ? Format.formatDate(galleryItem.metaData.dateTaken, Format.Timepoint)
                            : ""
                    details.cameraManufacturerDetail.value = galleryItem.metaData.cameraManufacturer
                    details.cameraModelDetail.value = galleryItem.metaData.cameraModel
                    details.exposureTimeDetail.value = galleryItem.metaData.exposureTime
                    details.fNumberDetail.value = galleryItem.metaData.fNumber != ""
                            ? details.formatFNumber(galleryItem.metaData.fNumber)
                            : ""
                    details.flashEnabledDetail.value = galleryItem.metaData.flashEnabled != ""
                            ? flashValues[galleryItem.metaData.flashEnabled]
                            : ""
                    details.focalLengthDetail.value = galleryItem.metaData.focalLength != ""
                            ? details.formatFocalLength(galleryItem.metaData.focalLength)
                            : ""
                    details.meteringModeDetail.value = galleryItem.metaData.meteringMode != ""
                            ? meteringModeValues[galleryItem.metaData.meteringMode]
                            : ""
                    details.whiteBalanceDetail.value = galleryItem.metaData.whiteBalance != ""
                              ? whiteBalanceValues[galleryItem.metaData.whiteBalance]
                              : ""
                    details.gpsDetail.value = galleryItem.metaData.latitude != ""
                            ? details.formatGpsCoordinates(galleryItem.metaData.latitude,
                                                           galleryItem.metaData.longitude,
                                                           galleryItem.metaData.altitude)
                            : ""
                    details.descriptionDetail.value = galleryItem.metaData.description
                    details.copyrightDetail.value = galleryItem.metaData.copyright
                    details.authorDetail.value = galleryItem.metaData.author
                }

                if (itemType == DocumentGallery.Video) {
                    details.durationDetail.value = Format.formatDuration(galleryItem.metaData.duration, Formatter.DurationLong)
                }
            }
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: details.height

        ImageDetailsItem {
            id: details
        }

        VerticalScrollDecorator { }
    }
}
