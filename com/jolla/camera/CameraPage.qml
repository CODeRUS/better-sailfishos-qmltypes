import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Media 1.0
import com.jolla.camera 1.0
import QtMultimedia 5.4
import "capture"
import "gallery"

Page {
    id: page

    property alias viewfinder: captureView.viewfinder
    property bool galleryActive
    property url galleryView
    readonly property bool captureModeActive: switcherView.currentIndex === 1
    readonly property bool galleryVisible: galleryLoader.visible
    readonly property int galleryIndex: galleryLoader.item ? galleryLoader.item.currentIndex : 0
    readonly property QtObject captureModel: galleryLoader.item ? galleryLoader.item.captureModel : null

    function returnToCaptureMode() {
        switcherView.returnToCaptureMode()
    }

    allowedOrientations: captureView.inButtonLayout ? page.orientation : Orientation.All
    orientationTransitions: Transition {
        to: 'Portrait,Landscape,PortraitInverted,LandscapeInverted'
        from: 'Portrait,Landscape,PortraitInverted,LandscapeInverted'
        SequentialAnimation {
            PropertyAction {
                target: page
                property: 'orientationTransitionRunning'
                value: true
            }
            FadeAnimation {
                target: pageStack
                to: 0
                duration: 150
            }
            PropertyAction {
                target: page
                properties: 'width,height,rotation,orientation'
            }
            FadeAnimation {
                target: pageStack
                to: 1
                duration: 150
            }
            PropertyAction {
                target: page
                property: 'orientationTransitionRunning'
                value: false
            }
        }
    }

    ListView {
        id: switcherView

        readonly property bool transitioning: moving || returnToCaptureModeTimeout.running

        function returnToCaptureMode() {
            if (Qt.application.active) {
                if (pageStack.currentPage === page) {
                    returnToCaptureModeTimeout.restart()
                    switcherView.currentIndex = 1
                }
            } else {
                pageStack.pop(page, PageStackAction.Immediate)
                positionViewAtEnd()
            }
        }

        Timer {
            id: returnToCaptureModeTimeout
            interval: switcherView.highlightMoveDuration
        }

        width: page.width
        height: page.height
        orientation: ListView.Horizontal
        snapMode: ListView.SnapOneItem
        boundsBehavior: Flickable.StopAtBounds
        highlightRangeMode: ListView.StrictlyEnforceRange
        interactive: (!galleryLoader.item || !galleryLoader.item.positionLocked)
                     && !captureView.recording
        currentIndex: 1
        focus: true

        flickDeceleration: Theme.flickDeceleration
        maximumFlickVelocity: Theme.maximumFlickVelocity

        // Normally transition is handled through a different path when flicking,
        // avoid slow transition if triggered by ListView for some reason
        highlightMoveDuration: 300

        Keys.onPressed: {
            if (!event.isAutoRepeat && event.key == Qt.Key_Camera) {
                switcherView.returnToCaptureMode()
            }
        }

        model: VisualItemModel {
            Item {
                id: galleryItem

                width: page.width
                height: page.height

                Loader {
                    id: galleryLoader

                    anchors.fill: parent

                    asynchronous: true
                    visible: switcherView.moving || page.galleryActive || returnToCaptureModeTimeout.running
                }

                BusyIndicator {
                    id: galleryIndicator
                    visible: galleryLoader.status == Loader.Loading
                    anchors.centerIn: parent
                    size: BusyIndicatorSize.Large
                    running: true
                }
            }

            CaptureView {
                id: captureView

                readonly property real _viewfinderPosition: orientation == Orientation.Portrait || orientation == Orientation.Landscape
                                                            ? parent.x + x
                                                            : -parent.x - x
                width: page.width
                height: page.height

                active: true

                orientation: page.orientation
                pageRotation: page.rotation
                captureModel: page.captureModel

                visible: switcherView.moving || captureView.active

                onLoaded: {
                    if (galleryLoader.source == "") {
                        galleryLoader.setSource(galleryView, { page: page })
                    }
                }

                CameraRollHint { z: 2 }
                CameraModeHint { z: 2 }

                Binding {
                    target: captureView.viewfinder
                    property: "x"
                    value: captureView.isPortrait
                           ? captureView._viewfinderPosition
                           : 0
                }

                Binding {
                    target: captureView.viewfinder
                    property: "y"
                    value: !captureView.isPortrait
                           ? captureView._viewfinderPosition + (page.orientation == Orientation.Landscape
                                                                ? captureView.viewfinderOffset : -captureView.viewfinderOffset)
                           : (page.orientation == Orientation.Portrait ? captureView.viewfinderOffset
                                                                       : -captureView.viewfinderOffset)
                }
            }
        }

        onCurrentItemChanged: {
            if (!transitioning) {
                page.galleryActive = galleryItem.ListView.isCurrentItem
                captureView.active = captureView.ListView.isCurrentItem
            }
        }

        onTransitioningChanged: {
            if (!transitioning) {
                page.galleryActive = galleryItem.ListView.isCurrentItem
                captureView.active = captureView.ListView.isCurrentItem
            } else if (captureView.active) {
                if (galleryLoader.source == "") {
                    galleryLoader.setSource("gallery/GalleryView.qml", { page: page })
                } else if (galleryLoader.item) {
                    galleryLoader.item._positionViewAtBeginning()
                }
            }
        }
    }


    DisabledByMdmView {}

    ScreenBlank {
        suspend: (galleryLoader.item && galleryLoader.item.playing)
                 || captureView.camera.videoRecorder.recorderState == CameraRecorder.RecordingState
    }


}
