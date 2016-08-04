import QtQuick 2.0
import Sailfish.Silica 1.0
import QtDocGallery 5.0
import "private"

Page {
    id: detailsPage
    property alias modelItem: galleryItem.item

    allowedOrientations: Orientation.All

    // https://developer.gnome.org/ontology/stable/nmm-Flash.html
    property variant flashValues: {
        'http://www.tracker-project.org/temp/nmm#flash-on':
        //% "Did fire"
        qsTrId("gallery-value-flash-on"),
        'http://www.tracker-project.org/temp/nmm#flash-off':
        //% "Did not fire"
        qsTrId("gallery-value-flash-off")
    }

    // https://developer.gnome.org/ontology/stable/nmm-MeteringMode.html
    property variant meteringModeValues: {
        'http://www.tracker-project.org/temp/nmm#metering-mode-other':
        //% "Other"
        qsTrId("gallery-value-metering-mode-other"),
        'http://www.tracker-project.org/temp/nmm#metering-mode-partial':
        //% "Partial"
        qsTrId("gallery-value-metring-mode-partial"),
        'http://www.tracker-project.org/temp/nmm#metering-mode-pattern':
        //% "Pattern"
        qsTrId("gallery-value-metering-mode-pattern"),
        'http://www.tracker-project.org/temp/nmm#metering-mode-multispot':
        //% "Multispot
        qsTrId("gallery-value-metering-mode-multispot"),
        'http://www.tracker-project.org/temp/nmm#metering-mode-spot':
        //% "Spot"
        qsTrId("gallery-value-metering-mode-spot"),
        'http://www.tracker-project.org/temp/nmm#metering-mode-center-weighted-average':
        //% "Center Weighted Average"
        qsTrId("gallery-value-metering-mode-center-weighted-average"),
        'http://www.tracker-project.org/temp/nmm#metering-mode-average':
        //% "Average"
        qsTrId("gallery-value-metering-mode-average")
    }

    // https://developer.gnome.org/ontology/stable/nmm-WhiteBalance.html
    property variant whiteBalanceValues: {
        'http://www.tracker-project.org/temp/nmm#white-balance-manual':
        //% "Manual"
        qsTrId("gallery-value-white-balance-manual"),
        'http://www.tracker-project.org/temp/nmm#white-balance-auto':
        //% "Auto"
        qsTrId("gallery-value-white-balance-auto")
    }

    DocumentGalleryItem {
        id: galleryItem
        autoUpdate: false
        // See all properties at https://github.com/qtproject/qtdocgallery/blob/master/src/gallery/qdocumentgallery.h
        properties: [ 'fileName', 'fileSize', 'mimeType',
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
                      'latitude', 'longitude', 'altitude'
                    ]

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
                    flashEnabledItem.value = flashValues[galleryItem.metaData.flashEnabled]
                    focalLengthItem.value = galleryItem.metaData.focalLength != ""
                            //: Camera focal length in millimeters
                            //% "%1 mm"
                            ? qsTrId("gallery-value-focal-length").arg(galleryItem.metaData.focalLength) : ""
                    meteringModeItem.value = meteringModeValues[galleryItem.metaData.meteringMode]
                    whiteBalanceItem.value = whiteBalanceValues[galleryItem.metaData.whiteBalance]
                    gpsItem.value = galleryItem.metaData.latitude != ""
                            //: GPS coordinates
                            //% "Latitude %1 - Longitude %2 - Altitude %3"
                            ? qsTrId("gallery-value-gps").arg(galleryItem.metaData.latitude).arg(galleryItem.metaData.longitude).arg(galleryItem.metaData.altitude) : ""
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
                id: flashEnabledItem
                //% "Flash"
                label: qsTrId("gallery-la-flash-enabled")
                visible: value.length > 0
            }
            DetailItem {
                id: focalLengthItem
                //% "Focal Length"
                label: qsTrId("gallery-la-focal-length")
                visible: value.length > 0
            }
            DetailItem {
                id: meteringModeItem
                //% "Metering Mode"
                label: qsTrId("gallery-la-metering-mode")
                visible: value.length > 0
            }
            DetailItem {
                id: whiteBalanceItem
                //% "White Balance"
                label: qsTrId("gallery-la-white-balance")
                visible: value.length > 0
            }
            DetailItem {
                id: gpsItem
                //% "GPS"
                label: qsTrId("gallery-la-gps")
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
