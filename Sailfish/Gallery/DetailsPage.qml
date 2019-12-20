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
                      'description', 'copyright'
                    ]

        onStatusChanged: {
            if (status == DocumentGalleryItem.Finished) {
                filePathItem.value = galleryItem.metaData.filePath
                fileSizeItem.value = Format.formatFileSize(galleryItem.metaData.fileSize)
                typeItem.value = galleryItem.metaData.mimeType
                //: Pattern for image resolution, width x height
                //% "%1 × %2"
                sizeItem.value = qsTrId("components_gallery-size_format").arg(galleryItem.metaData.width).arg(galleryItem.metaData.height)

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
                            ? qsTrId("components_gallery-value-fnumber").arg(galleryItem.metaData.fNumber) : ""

                    flashEnabledItem.value = galleryItem.metaData.flashEnabled != ""
                            ? flashValues[galleryItem.metaData.flashEnabled]
                            : ""
                    focalLengthItem.value = galleryItem.metaData.focalLength != ""
                            //: Camera focal length in millimeters
                            //% "%1 mm"
                            ? qsTrId("components_gallery-value-focal-length").arg(galleryItem.metaData.focalLength) : ""
                    meteringModeItem.value = galleryItem.metaData.meteringMode != ""
                            ? meteringModeValues[galleryItem.metaData.meteringMode]
                            : ""
                    whiteBalanceItem.value = galleryItem.metaData.whiteBalance != ""
                              ? whiteBalanceValues[galleryItem.metaData.whiteBalance]
                              : ""
                    gpsItem.value = galleryItem.metaData.latitude != ""
                            //: GPS coordinates
                            //% "Latitude %1 - Longitude %2 - Altitude %3"
                            ? qsTrId("components_gallery-value-gps")
                              .arg(galleryItem.metaData.latitude)
                              .arg(galleryItem.metaData.longitude)
                              .arg(galleryItem.metaData.altitude)
                            : ""
                    descriptionItem.value = galleryItem.metaData.description
                    copyrightItem.value = galleryItem.metaData.copyright
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
            bottomPadding: Theme.paddingLarge

            PageHeader {
                //% "Details"
                title: qsTrId("components_gallery-he-details")
            }
            DetailItem {
                id: filePathItem
                //% "File path"
                label: qsTrId("components_gallery-la-file_path")
                alignment: Qt.AlignLeft
            }
            DetailItem {
                id: fileSizeItem
                //% "File size"
                label: qsTrId("components_gallery-la-file_size")
                alignment: Qt.AlignLeft
            }
            DetailItem {
                id: typeItem
                //% "Type"
                label: qsTrId("components_gallery-la-type")
                alignment: Qt.AlignLeft
            }
            DetailItem {
                id: sizeItem
                //% "Size"
                label: qsTrId("components_gallery-la-size")
                alignment: Qt.AlignLeft
            }
            DetailItem {
                id: dateTakenItem
                //% "Date Taken"
                label: qsTrId("components_gallery-la-date-taken")
                visible: value.length > 0
                alignment: Qt.AlignLeft
            }
            DetailItem {
                id: cameraManufacturerItem
                //% "Camera Manufacturer"
                label: qsTrId("components_gallery-la-camera-manufacturer")
                visible: value.length > 0
                alignment: Qt.AlignLeft
            }
            DetailItem {
                id: cameraModelItem
                //% "Camera Model"
                label: qsTrId("components_gallery-la-camera-model")
                visible: value.length > 0
                alignment: Qt.AlignLeft
            }
            DetailItem {
                id: exposureTimeItem
                //% "Exposure Time"
                label: qsTrId("components_gallery-la-exposure-time")
                visible: value.length > 0 && value != "0"
                alignment: Qt.AlignLeft
            }
            DetailItem {
                id: fNumberItem
                //% "Aperture"
                label: qsTrId("components_gallery-la-aperture")
                visible: value.length > 0
                alignment: Qt.AlignLeft
            }
            DetailItem {
                id: flashEnabledItem
                //% "Flash"
                label: qsTrId("components_gallery-la-flash-enabled")
                visible: value.length > 0
                alignment: Qt.AlignLeft
            }
            DetailItem {
                id: focalLengthItem
                //% "Focal Length"
                label: qsTrId("components_gallery-la-focal-length")
                visible: value.length > 0
                alignment: Qt.AlignLeft
            }
            DetailItem {
                id: meteringModeItem
                //% "Metering Mode"
                label: qsTrId("components_gallery-la-metering-mode")
                visible: value.length > 0
                alignment: Qt.AlignLeft
            }
            DetailItem {
                id: whiteBalanceItem
                //% "White Balance"
                label: qsTrId("components_gallery-la-white-balance")
                visible: value.length > 0
                alignment: Qt.AlignLeft
            }
            DetailItem {
                id: gpsItem
                //% "GPS"
                label: qsTrId("components_gallery-la-gps")
                visible: value.length > 0
                alignment: Qt.AlignLeft
            }
            DetailItem {
                id: durationItem
                //% "Duration"
                label: qsTrId("components_gallery-la-duration")
                visible: value.length > 0
                alignment: Qt.AlignLeft
            }
            DetailItem {
                id: descriptionItem
                //% "Description"
                label: qsTrId("components_gallery-la-description")
                visible: value.length > 0
                alignment: Qt.AlignLeft
            }
            DetailItem {
                id: copyrightItem
                //% "Copyright"
                label: qsTrId("components_gallery-la-copyright")
                visible: value.length > 0
                alignment: Qt.AlignLeft
            }
        }
        VerticalScrollDecorator { }
    }
}
