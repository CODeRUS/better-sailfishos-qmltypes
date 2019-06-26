import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Gallery 1.0
import Sailfish.Gallery.private 1.0

SilicaFlickable {
    id: flickable

    property bool scaled: false

    property bool viewMoving
    readonly property bool enableZoom: !viewMoving
    property alias source: photo.source
    property int fit: isPortrait ? Fit.Width : Fit.Height

    property bool active: true
    property alias pressed: mouseArea.pressed
    readonly property bool error: photo.status == Image.Error

    property alias photo: photo
    property alias largePhoto: largePhoto

    property real minimumScale: -1
    property real fittedScale: -1

    property real _fittedScale: fittedScale > 0 ? fittedScale : Math.min(maximumZoom, Math.min(width / implicitWidth, height / implicitHeight))
    property real _minimumScale: minimumScale > 0 ? minimumScale : _fittedScale

    property real _scale
    property int orientation: metadata.orientation

    // Calculate a default value which produces approximately same level of zoom
    // on devices with different screen resolutions.
    property real maximumZoom: Math.max(Screen.width, Screen.height) / 200
    property int _maximumZoomedWidth: _fullWidth * maximumZoom
    property int _maximumZoomedHeight: _fullHeight * maximumZoom
    property int _minimumZoomedWidth: implicitWidth * _minimumScale
    property int _minimumZoomedHeight: implicitHeight * _minimumScale
    property bool _zoomAllowed: enableZoom && _minimumScale !== maximumZoom
    property int _fullWidth: transpose ? Math.max(photo.implicitHeight, largePhoto.implicitHeight)
                                        : Math.max(photo.implicitWidth, largePhoto.implicitWidth)
    property int _fullHeight: transpose ? Math.max(photo.implicitWidth, largePhoto.implicitWidth)
                                         : Math.max(photo.implicitHeight, largePhoto.implicitHeight)

    // Note transpose is used by ZoomableImage
    property bool transpose: (orientation % 180) != 0

    signal clicked

    // Override SilicaFlickable's pressDelay because otherwise it will
    // block touch events going to PinchArea in certain cases.
    pressDelay: 0

    enabled: !zoomOutAnimation.running
    flickableDirection: Flickable.HorizontalAndVerticalFlick

    implicitWidth: transpose ? photo.implicitHeight : photo.implicitWidth
    implicitHeight: transpose ? photo.implicitWidth : photo.implicitHeight

    contentWidth: container.width
    contentHeight: container.height

    readonly property bool _active: active || viewMoving
    on_ActiveChanged: {
        if (!_active) {
            resetScale()
            largePhoto.source = ""
        }
    }
    onViewMovingChanged: if (!viewMoving) mouseArea.reset()
    interactive: (scaled || leftMargin > 0 || rightMargin > 0 || topMargin > 0 || bottomMargin > 0) && !mouseArea.horizontalDragUnused

    function resetScale() {
        if (scaled) {
            _scale = _fittedScale
            scaled = false
        }
    }

    function _scaleImage(scale, center, prevCenter) {
        if (largePhoto.source != photo.source) {
            largePhoto.source = photo.source
        }

        var newWidth
        var newHeight
        var oldWidth = contentWidth
        var oldHeight = contentHeight

        if (fit == Fit.Width) {
            // Scale and bounds check the width, and then apply the same scale to height.
            newWidth = (flickable.transpose ? photo.height : photo.width) * scale
            if (newWidth <= flickable._minimumZoomedWidth) {
                _scale = _minimumScale
                return
            } else {
                newWidth = Math.min(newWidth, flickable._maximumZoomedWidth)
                _scale = newWidth / implicitWidth
                newHeight = transpose ? photo.width : photo.height
            }
        } else {
            // Scale and bounds check the height, and then apply the same scale to width.
            newHeight = (flickable.transpose ? photo.width : photo.height) * scale
            if (newHeight <= flickable._minimumZoomedHeight) {
                _scale = _minimumScale
                return
            } else {
                newHeight = Math.min(newHeight, flickable._maximumZoomedHeight)
                _scale = newHeight / implicitHeight
                newWidth = transpose ? photo.height : photo.width
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

    Binding { // Update scale on orientation changes
        target: flickable
        when: !scaled
        property: "_scale"
        value: _fittedScale
    }

    Binding { // Allow vertical page navigation when panning the image near the top or bottom edge
        target: pageStack
        when: root.visible
        property: "_noGrabbing"
        value: mouseArea.verticalDragUnused
    }

    // Make sure that _noGrabbing will be reset back to false (JB#42531)
    Component.onDestruction: {
        if (!root || !root.visible)
            pageStack._noGrabbing = false
    }

    Connections {
        target: pageStack
        onDragInProgressChanged: {
            if (pageStack.dragInProgress && pageStack._noGrabbing) {
                pageStack._grabMouse()
            }
        }
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
        onPinchUpdated: if (flickable._zoomAllowed) flickable._scaleImage(1.0 + pinch.scale - pinch.previousScale, pinch.center, pinch.previousCenter)
        onPinchFinished: flickable.returnToBounds()
        width: Math.max(flickable.width, flickable.transpose ? photo.height : photo.width)
        height: Math.max(flickable.height, flickable.transpose ? photo.width : photo.height)

        Image {
            id: photo
            property var errorLabel
            objectName: "zoomableImage"

            smooth: !(flickable.movingVertically || flickable.movingHorizontally)
            width: Math.ceil(implicitWidth * flickable._scale)
            height: Math.ceil(implicitHeight * flickable._scale)
            sourceSize.width: Screen.height
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            anchors.centerIn: parent
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

        MouseArea {
            id: mouseArea

            property int startX
            property int startY
            property bool horizontalDragUnused
            property bool verticalDragUnused

            function reset() {
                verticalDragUnused = false
                horizontalDragUnused = false
            }
            onPressed: {
                reset()
                startX = mouseX
                startY = mouseY
            }
            onPositionChanged: {
                if (container.pinch.active) return
                if (mouseX - startX > Theme.startDragDistance && flickable.atXBeginning
                        || mouseX - startX < -Theme.startDragDistance && flickable.atXEnd) {
                    horizontalDragUnused = true
                } else if (mouseY - startY > Theme.startDragDistance && flickable.atYBeginning
                           || mouseY - startY < -Theme.startDragDistance && flickable.atYEnd) {

                    verticalDragUnused = true
                }
            }
            onClicked: flickable.clicked()
            onDoubleClicked: {
                if (_scale !== _fittedScale) {
                    zoomOutAnimation.start()
                }
            }

            anchors.fill: parent

            ParallelAnimation {
                id: zoomOutAnimation
                SequentialAnimation {
                    NumberAnimation {
                        target: flickable
                        property: "_scale"
                        to: _fittedScale
                        easing.type: Easing.InOutQuad
                        duration: 200
                    }
                    ScriptAction {
                        script: scaled = false
                    }
                }
                NumberAnimation {
                    target: flickable
                    properties: "contentX, contentY"
                    to: 0
                    easing.type: Easing.InOutQuad
                    duration: 200
                }
            }
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
