import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Gallery 1.0
import Sailfish.Gallery.private 1.0

SilicaFlickable {
    id: flickable

    property bool scaled: false
    property bool menuOpen
    property bool enableZoom
    property alias source: photo.source
    property int fit

    property bool active: true

    property real _fittedScale: Math.min(maximumZoom, Math.min(width / implicitWidth,
                                                               height / implicitHeight))
    property real _menuOpenScale: Math.max(_viewOpenWidth / implicitWidth,
                                           _viewOpenHeight / implicitHeight)
    property real _scale

    property int orientation: metadata.orientation

    // Calculate a default value which produces approximately same level of zoom
    // on devices with different screen resolutions.
    property real maximumZoom: Math.max(Screen.width, Screen.height) / 200
    property int _maximumZoomedWidth: _fullWidth * maximumZoom
    property int _maximumZoomedHeight: _fullHeight * maximumZoom
    property int _minimumZoomedWidth: implicitWidth * _fittedScale
    property int _minimumZoomedHeight: implicitHeight * _fittedScale
    property bool _zoomAllowed: enableZoom && !menuOpen && _fittedScale !== maximumZoom && !_menuAnimating
    property int _fullWidth: _transpose ? Math.max(photo.implicitHeight, largePhoto.implicitHeight)
                                        : Math.max(photo.implicitWidth, largePhoto.implicitWidth)
    property int _fullHeight: _transpose ? Math.max(photo.implicitWidth, largePhoto.implicitWidth)
                                         : Math.max(photo.implicitHeight, largePhoto.implicitHeight)

    property int _viewOrientation: fit == Fit.Width ? Orientation.Portrait : Orientation.Landscape
    property int _viewOpenWidth: _viewOrientation == Orientation.Portrait ? Screen.width : Screen.height / 2
    property int _viewOpenHeight: _viewOrientation == Orientation.Portrait ? Screen.height / 2 : Screen.width

    readonly property bool _transpose: (orientation % 180) != 0
    property bool _menuAnimating

    signal clicked

    // Override SilicaFlickable's pressDelay because otherwise it will
    // block touch events going to PinchArea in certain cases.
    pressDelay: 0

    flickableDirection: Flickable.HorizontalAndVerticalFlick

    implicitWidth: _transpose ? photo.implicitHeight : photo.implicitWidth
    implicitHeight: _transpose ? photo.implicitWidth : photo.implicitHeight

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

        if (fit == Fit.Width) {
            // Scale and bounds check the width, and then apply the same scale to height.
            newWidth = (flickable._transpose ? photo.height : photo.width) * scale
            if (newWidth <= flickable._minimumZoomedWidth) {
                _resetScale()
                return
            } else {
                newWidth = Math.min(newWidth, flickable._maximumZoomedWidth)
                _scale = newWidth / implicitWidth
                newHeight = _transpose ? photo.width : photo.height
            }
        } else {
            // Scale and bounds check the height, and then apply the same scale to width.
            newHeight = (flickable._transpose ? photo.width : photo.height) * scale
            if (newHeight <= flickable._minimumZoomedHeight) {
                _resetScale()
                return
            } else {
                newHeight = Math.min(newHeight, flickable._maximumZoomedHeight)
                _scale = newHeight / implicitHeight
                newWidth = _transpose ? photo.height : photo.width
            }
        }

        // move center
        contentX += prevCenter.x - center.x
        contentY += prevCenter.y - center.y

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
        enabled: photo.status == Image.Ready
        onPinchStarted: if (flickable.menuOpen) flickable.clicked()
        onPinchUpdated: if (flickable._zoomAllowed) flickable._scaleImage(1.0 + pinch.scale - pinch.previousScale, pinch.center, pinch.previousCenter)
        onPinchFinished: flickable.returnToBounds()
        width: Math.max(flickable.width, flickable._transpose ? photo.height : photo.width)
        height: Math.max(flickable.height, flickable._transpose ? photo.width : photo.height)

        Image {
            id: photo
            property var errorLabel
            objectName: "zoomableImage"

            smooth: !(flickable.movingVertically || flickable.movingHorizontally)
            width: Math.ceil(implicitWidth * flickable._scale)
            height: Math.ceil(implicitHeight * flickable._scale)
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
                _scale: flickable._fittedScale
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
            SequentialAnimation {
                ScriptAction { script: flickable._menuAnimating = true }
                PropertyAnimation {
                    target: flickable
                    properties: "_scale,contentX,contentY"
                    duration: 300
                    easing.type: Easing.InOutCubic
                }
                ScriptAction { script: flickable._menuAnimating = false }
            }
        },
        Transition {
            from: 'menuOpen'
            to: '*'
            SequentialAnimation {
                ScriptAction { script: flickable._menuAnimating = true }
                PropertyAnimation {
                    target: flickable
                    properties: "_scale,contentX,contentY"
                    duration: 300
                    easing.type: Easing.InOutCubic
                }
                ScriptAction { script: flickable._menuAnimating = false }
            }
        }
    ]

}
