import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0
import Sailfish.Gallery 1.0
import Sailfish.Gallery.private 1.0

ZoomableFlickable {
    id: flickable

    property alias source: photo.source

    property bool active: true
    readonly property bool _active: active || viewMoving
    readonly property bool error: photo.status == Image.Error
    readonly property alias imageMetaData: metadata

    property alias photo: photo
    property alias largePhoto: largePhoto

    signal clicked

    onAboutToZoom: {
        if (largePhoto.source != photo.source) {
            largePhoto.source = photo.source
        }
    }

    contentRotation: -metadata.orientation
    scrollDecoratorColor: Theme.lightPrimaryColor

    zoomEnabled: photo.status == Image.Ready
    maximumZoom: Math.max(Screen.width, Screen.height) / 200
                 * Math.max(1.0, photo.implicitWidth > 0 ? largePhoto.implicitHeight / photo.implicitHeight
                                                         : 1.0)

    on_ActiveChanged: {
        if (!_active) {
            resetZoom()
            largePhoto.source = ""
        }
    }

    implicitContentWidth: photo.implicitWidth
    implicitContentHeight: photo.implicitHeight

    Image {
        id: photo
        property var errorLabel
        objectName: "zoomableImage"

        anchors.fill: parent
        smooth: !(movingVertically || movingHorizontally)
        sourceSize.width: Screen.height
        fillMode: Image.PreserveAspectFit
        visible: largePhoto.status !== Image.Ready
        asynchronous: true
        cache: false

        onStatusChanged: {
            if (status == Image.Error) {
                errorLabel = errorLabelComponent.createObject(photo)
            }
        }

        onSourceChanged: {
            if (errorLabel) {
                errorLabel.destroy()
                errorLabel = null
            }

            resetZoom()
        }

        opacity: status == Image.Ready ? 1 : 0
        Behavior on opacity { FadeAnimation{} }
    }

    Image {
        id: largePhoto
        sourceSize {
            width: 3264
            height: 3264
        }
        cache: false
        asynchronous: true
        anchors.fill: parent
    }

    MouseArea {
        parent: _dragDetector // don't catch multi touch events (position behind ZoomableFlickable.pinchArea)
        anchors {
            fill: parent
            margins: Theme.paddingLarge // don't react near display edges
        }
        onClicked: flickable.clicked()
    }

    ImageMetadata {
        id: metadata

        source: photo.source
        autoUpdate: false
    }

    BusyIndicator {
        running: photo.status === Image.Loading && !delayBusyIndicator.running
        size: BusyIndicatorSize.Large
        anchors.centerIn: parent
        Timer {
            id: delayBusyIndicator
            running: photo.status === Image.Loading
            interval: 1000
        }
    }

    Component {
        id: errorLabelComponent
        InfoLabel {
            //: Image loading failed
            //% "Oops, can't display the image"
            text: qsTrId("components_gallery-la-image-loading-failed")
            anchors.verticalCenter: parent.verticalCenter
            opacity: photo.status == Image.Error ? 1.0 : 0.0
            Behavior on opacity { FadeAnimator {}}
        }
    }
}
