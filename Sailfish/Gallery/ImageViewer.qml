import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Gallery 1.0
import Sailfish.Gallery.private 1.0

SilicaFlickable {
    id: flickable

    property bool scaled: false
    property bool menuOpen
    property bool enableZoom: !menuOpen
    property alias source: photo.source
    property int fit

    property bool active: true

    property real _fittedScale: Math.min(width / implicitWidth, height / implicitHeight)
    property real _menuOpenScale: Math.max(_viewOpenWidth / implicitWidth, _viewOpenHeight / implicitHeight)
    property real _scale

    property int orientation: metadata.orientation

    property int maximumWidth
    property int maximumHeight

    // Prefer the maximumWidth and maximumHeight values supplied by the user as these may be more
    // cheaply obtained, but if those values aren't valid then fall back to the ImageMetadata type.
    property int _actualWidth: maximumWidth > 1 ? maximumWidth : metadata.width
    property int _actualHeight: maximumHeight > 1 ? maximumHeight : metadata.height

    property int _viewOrientation: fit == Fit.Width ? Orientation.Portrait : Orientation.Landscape
    property int _viewOpenWidth: _viewOrientation == Orientation.Portrait ? Screen.width : Screen.height / 2
    property int _viewOpenHeight: _viewOrientation == Orientation.Portrait ? Screen.height / 2 : Screen.width

    readonly property bool _transpose: (orientation % 180) != 0

    signal clicked

    // Override SilicaFlickable's pressDelay because otherwise it will
    // block touch events going to PinchArea in certain cases.
    pressDelay: 0

    flickableDirection: Flickable.HorizontalAndVerticalFlick

    implicitWidth: !_transpose ? flickable._actualWidth : flickable._actualHeight
    implicitHeight: !_transpose ? flickable._actualHeight : flickable._actualWidth

    contentWidth: container.width
    contentHeight: container.height

    // Only update the scale when width and height are properly set by Silica.
    // If we do it too early, then calculating a new _fittedScale goes wrong
    on_ViewOrientationChanged: {
        _updateScale()
    }

    onActiveChanged: {
        if (!active) {
            _resetScale()
            largePhoto.source = ""
        }
    }

    interactive: scaled

    function _resetScale()
    {
        if (scaled) {
            _scale = _fittedScale
            scaled = false
        }
    }

    function _scaleImage(scale, center, prevCenter)
    {
        if (largePhoto.source != photo.source) {
            largePhoto.source = photo.source
        }
        var newWidth
        var newHeight
        var oldWidth = contentWidth
        var oldHeight = contentHeight

        // move center
        contentX += prevCenter.x - center.x
        contentY += prevCenter.y - center.y

        if (fit == Fit.Width) {
            // Scale and bounds check the width, and then apply the same scale to height.
            newWidth = (!flickable._transpose ? photo.width : photo.height) * scale

            if (newWidth <= _fittedScale * flickable.implicitWidth) {
                _resetScale()
                return
            } else {
                newWidth = Math.min(newWidth, flickable._actualWidth)
                _scale = newWidth / flickable.implicitWidth
                newHeight = Math.max(!_transpose ? photo.height : photo.width, Screen.height)
            }
        } else {
            // Scale and bounds check the height, and then apply the same scale to width.
            newHeight = (!flickable._transpose ? photo.height: photo.width) * scale
            if (newHeight <= _fittedScale * flickable.implicitHeight) {
                _resetScale()
                return
            } else {
                newHeight = Math.min(newHeight, flickable._actualHeight)
                _scale = newHeight / flickable.implicitHeight
                newWidth = Math.max(!_transpose ? photo.width : photo.height, Screen.height)
            }
        }

        // scale about center
        if (newWidth > flickable.width)
            contentX -= (oldWidth - newWidth)/(oldWidth/prevCenter.x)
        if (newHeight > flickable.height)
            contentY -= (oldHeight - newHeight)/(oldHeight/prevCenter.y)

        scaled = true
    }

    function _updateScale() {
        if (photo.status != Image.Ready) {
            return
        }
        state = menuOpen
                ? "menuOpen"
                : _viewOrientation == Orientation.Portrait
                ? "portrait"
                : _viewOrientation == Orientation.Landscape
                ? "landscape"
                : "fullscreen" // fallback
    }

    ImageMetadata {
        id: metadata

        source: photo.source
        autoUpdate: false
    }

    children: ScrollDecorator {}

    PinchArea {
        id: container
        enabled: !flickable.menuOpen && flickable.enableZoom && photo.status == Image.Ready
        onPinchUpdated: flickable._scaleImage(1.0 + pinch.scale - pinch.previousScale, pinch.center, pinch.previousCenter)
        onPinchFinished: flickable.returnToBounds()
        width: Math.max(flickable.width, !flickable._transpose ? photo.width : photo.height)
        height: Math.max(flickable.height, !flickable._transpose ? photo.height : photo.width)

        Image {
            id: photo
            property var errorLabel
            objectName: "zoomableImage"

            smooth: !(flickable.movingVertically || flickable.movingHorizontally)
            width: Math.ceil(flickable._actualWidth * flickable._scale)
            height: Math.ceil(flickable._actualHeight * flickable._scale)
            sourceSize.width: Screen.height
            fillMode:  Image.PreserveAspectFit
            asynchronous: true
            anchors.centerIn: parent
            cache: false

            horizontalAlignment: Image.Left
            verticalAlignment: Image.Top

            onStatusChanged: {

                if (status == Image.Ready) {
                    flickable._updateScale()
                }

                if (status == Image.Error) {
                   errorLabel = errorLabelComponent.createObject(photo)
                }
            }

            onSourceChanged: {
                if (errorLabel) {
                    errorLabel.destroy()
                }

                flickable.scaled = false
            }

            rotation: -flickable.orientation

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
            anchors.fill: photo
            rotation: -flickable.orientation
        }

        MouseArea {
            anchors.fill: parent
            enabled: !flickable.scaled

            onClicked: {
                flickable.clicked()
            }
        }
    }

    Component {
        id: errorLabelComponent
        Label {
            //: Image loading failed
            //% "Oops, can't display the image"
            text: qsTrId("components_gallery-la-image-loading-failed")
            anchors.centerIn: parent
            width: parent.width - 2 * Theme.paddingMedium
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
        }
    }
    // Let the states handle switching between menu open and fullscreen states.
    // We need to extend fullscreen state with two different states: portrait and
    // landscape to make it actually reset the fitted scale via state changes when
    // the orientation changes. Ie. state change from "fullscreen" to "fullscreen"
    // doesn't reset the fitted scale.
    states: [
        State {
            name: "menuOpen"
            when: flickable.menuOpen && photo.status === Image.Ready
            PropertyChanges {
                target: flickable
                _scale: flickable._menuOpenScale
                scaled: false
                contentX: fit == Fit.Width ? (flickable.implicitWidth  * flickable._menuOpenScale - flickable._viewOpenWidth ) / (flickable._viewOrientation == Orientation.Portrait ? 2 : -2) : 0
                contentY: fit == Fit.Width ? 0 : (flickable.implicitHeight  * flickable._menuOpenScale - flickable._viewOpenHeight ) / (flickable._viewOrientation == Orientation.Portrait ? -2 : 2)
            }
        },
        State {
            name: "fullscreen"
            PropertyChanges {
                target: flickable
                // 1.0 for smaller images. _fittedScale for images which are larger than view
                _scale: flickable._fittedScale >= 1 ? 1.0 : flickable._fittedScale
                scaled: false
                contentX: 0
                contentY: 0
            }
        },
        State {
            when: !flickable.menuOpen && photo.status === Image.Ready && _viewOrientation === Orientation.Portrait
            name: "portrait"
            extend: "fullscreen"
        },
        State {
            when: !flickable.menuOpen && photo.status === Image.Ready && _viewOrientation === Orientation.Landscape
            name: "landscape"
            extend: "fullscreen"
        }
    ]

    transitions: [
        Transition {
            from: '*'
            to: 'menuOpen'
            PropertyAnimation {
                target: flickable
                properties: "_scale,contentX,contentY"
                duration: 300
                easing.type: Easing.InOutCubic
            }
        },
        Transition {
            from: 'menuOpen'
            to: '*'
            PropertyAnimation {
                target: flickable
                properties: "_scale,contentX,contentY"
                duration: 300
                easing.type: Easing.InOutCubic
            }
        }
    ]
}
