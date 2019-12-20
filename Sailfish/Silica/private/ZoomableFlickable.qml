import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0

SilicaFlickable {
    id: flickable

    property real zoom
    property bool zoomed

    property real minimumZoom: fittedZoom
    property real maximumZoom: 2.5
    property real implicitFittedZoom: _implicitContentWidth > 0 && _implicitContentHeight > 0
                                      ? Math.min(maximumZoom, Math.min(width / _implicitContentWidth,
                                                                       height / _implicitContentHeight))
                                      : 1.0

    property real fittedZoom: implicitFittedZoom

    property bool zoomEnabled: true
    property bool viewMoving

    property bool transpose: (contentRotation % 180) != 0
    property int fit: width < height ? Qt.Horizontal : Qt.Vertical

    property Item _dragDetector: dragDetector
    property alias contentRotation: rotatingItem.rotation
    default property alias rotatingItem: rotatingItem.data

    signal aboutToZoom
    signal zoomFinished

    function resetZoom() {
        if (zoomed) {
            zoom = fittedZoom
            zoomed = false
        }
    }

    function zoomOut() {
        zoomOutAnimation.start()
    }

    function zoomIn(targetZoom, targetCenter, prevCenter) {
        aboutToZoom()

        var newWidth
        var newHeight
        var oldWidth = contentWidth
        var oldHeight = contentHeight

        if (fit == Qt.Horizontal) {
            // Zoom and bounds check the width, and then apply the same zoom to height.
            newWidth = contentWidth * targetZoom
            if (newWidth <= _implicitContentWidth * minimumZoom) {
                zoom = minimumZoom
                return
            } else {
                newWidth = Math.min(newWidth, _implicitContentWidth * maximumZoom)
                zoom = newWidth / _implicitContentWidth
                newHeight = _implicitContentHeight * zoom
            }
        } else {
            // Zoom and bounds check the height, and then apply the same zoom to width.
            newHeight = contentHeight * targetZoom
            if (newHeight <= _implicitContentHeight * minimumZoom) {
                zoom = minimumZoom
                return
            } else {
                newHeight = Math.min(newHeight, _implicitContentWidth * maximumZoom)
                zoom = newHeight / _implicitContentHeight
                newWidth = _implicitContentWidth * zoom
            }
        }

        // move center
        contentX += prevCenter.x - targetCenter.x
        contentY += prevCenter.y - targetCenter.y

        // zoom about center
        if (newWidth > width)
            contentX -= (oldWidth - newWidth)/(oldWidth/prevCenter.x)
        if (newHeight > height)
            contentY -= (oldHeight - newHeight)/(oldHeight/prevCenter.y)

        zoomed = true
    }

    // Override SilicaFlickable's pressDelay because otherwise it will
    // block touch events going to PinchArea in certain cases.
    pressDelay: 0

    contentWidth: Math.max(width, transpose ? rotatingItem.height : rotatingItem.width)
    contentHeight: Math.max(height, transpose ? rotatingItem.width : rotatingItem.height)

    property alias implicitContentWidth: rotatingItem.implicitWidth
    property alias implicitContentHeight: rotatingItem.implicitHeight

    // dimensions after rotating the content item
    property real _implicitContentWidth: transpose ? implicitContentHeight : implicitContentWidth
    property real _implicitContentHeight: transpose ? implicitContentWidth : implicitContentHeight
    property alias scrollDecoratorColor: scrollDecorator.color

    enabled: !zoomOutAnimation.running
    flickableDirection: Flickable.HorizontalAndVerticalFlick

    onViewMovingChanged: if (!viewMoving) dragDetector.reset()
    interactive: {
        if (dragDetector.horizontalDragUnused || dragDetector.verticalDragUnused) {
            return false
        }
        if (zoomed) {
            return true
        } else if (leftMargin > 0 || rightMargin > 0 || topMargin > 0 || bottomMargin > 0) {
            return true
        } else {
            return false
        }
    }
    ScrollDecorator { id: scrollDecorator }

    Binding { // Update zoom on orientation changes
        target: flickable
        when: !zoomed
        property: "zoom"
        value: fittedZoom
    }

    Binding { // Allow page navigation when panning the image near the top or bottom edge
        target: pageStack
        when: flickable.visible && !!flickable.page
        property: "_noGrabbing"
        value: dragDetector.verticalDragUnused || dragDetector.horizontalDragUnused
    }

    // Make sure that _noGrabbing will be reset back to false (JB#42531)
    Component.onDestruction: {
        if (!visible)
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

    PinchArea {
        id: pinchArea
        parent: flickable.contentItem
        width: flickable.contentWidth
        height: flickable.contentHeight

        // Otherwise first pinch fails
        enabled: implicitContentWidth > 0 && implicitContentHeight > 0
        onPinchUpdated: {
            if (zoomEnabled && !viewMoving && minimumZoom !== maximumZoom) {
                zoomIn(1.0 + pinch.scale - pinch.previousScale, pinch.center, pinch.previousCenter)
            }
        }
        onPinchFinished: {
            zoomFinished()
            returnToBounds()
        }

        DragDetectorItem {
            id: dragDetector
            flickable: flickable
            anchors.fill: parent
            Item {
                id: rotatingItem
                anchors.centerIn: parent
                implicitWidth: flickable.width
                implicitHeight: flickable.height
                width: Math.ceil(implicitWidth * zoom)
                height: Math.ceil(implicitHeight * zoom)
            }
        }
    }

    ParallelAnimation {
        id: zoomOutAnimation
        SequentialAnimation {
            NumberAnimation {
                target: flickable
                property: "zoom"
                to: fittedZoom
                easing.type: Easing.InOutQuad
                duration: 200
            }
            ScriptAction {
                script: zoomed = false
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
