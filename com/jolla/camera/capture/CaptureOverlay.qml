import QtQuick 2.0
import QtMultimedia 5.4
import QtPositioning 5.1
import Sailfish.Silica 1.0
import Sailfish.Media 1.0
import com.jolla.camera 1.0
import org.nemomobile.time 1.0
import org.nemomobile.policy 1.0
import org.nemomobile.ngf 1.0
import org.nemomobile.configuration 1.0
import org.nemomobile.notifications 1.0
import QtSystemInfo 5.0

import "../settings"

SettingsOverlay {
    id: settingsOverlay

    property var captureView
    property var camera
    property Item focusArea
    property alias captureButtonPressed: captureButton.pressed

    property int _recordingDuration: clock.enabled ? ((clock.time - _startTime) / 1000) : 0
    property var _startTime: new Date()

    width: captureView.width
    height: captureView.height

    function writeMetaData() {
        captureView.captureOrientation = captureView.viewfinderOrientation
        // Camera documentation says dateTimeOriginal should be used but at the moment CameraBinMetaData uses only
        // date property (which the documentation doesn't even list)
        camera.metaData.date = new Date()

        if (positionSource.active) {
            var coordinate = positionSource.position.coordinate
            if (coordinate.isValid) {
                camera.metaData.gpsLatitude = coordinate.latitude
                camera.metaData.gpsLongitude = coordinate.longitude
            } else {
                camera.metaData.gpsLatitude = undefined
                camera.metaData.gpsLongitude = undefined
            }
            camera.metaData.gpsAltitude = positionSource.position.altitudeValid
                        ? coordinate.altitude
                        : undefined
        } else {
            camera.metaData.gpsLatitude = undefined
            camera.metaData.gpsLongitude = undefined
            camera.metaData.gpsAltitude = undefined
        }
    }

    readonly property int storagePathStatus: Settings.storagePathStatus
    onStoragePathStatusChanged: checkStorage()

    readonly property bool _applicationActive: Qt.application.state == Qt.ApplicationActive
    on_ApplicationActiveChanged: if (_applicationActive) checkStorage()

    Component.onCompleted: checkStorage()

    function checkStorage() {
        if (Qt.application.state != Qt.ApplicationActive) {
            // We don't want to show notification when we're in the background
            return
        }

        var prevStatus = previousStoragePathStatus.value
        if (Settings.storagePathStatus == Settings.Unavailable) {
            if (prevStatus != Settings.storagePathStatus) {
                //% "The selected storage is unavailable. Device memory will be used instead"
                notification.publishMessage(qsTrId("camera-me-storage-unavailable"))
            }
        } else if (Settings.storagePathStatus == Settings.Available) {
            if (prevStatus == Settings.Unavailable || prevStatus == Settings.Mounting) {
                //% "Using memory card"
                notification.publishMessage(qsTrId("camera-me-using-memory-card"))
            }
        } else if (Settings.storagePathStatus == Settings.Mounting) {
            //% "Busy mounting the memory card. Device memory will be used instead"
            notification.publishMessage(qsTrId("camera-me-storage-mounting"))
        }
        previousStoragePathStatus.value = Settings.storagePathStatus
    }

    PositionSource {
        id: positionSource
        // QDeclarativePositionSource::active property is not well behaved.
        // The internal position source may not be initialised until the component completes,
        // and in that instance the active property may be reset.
        // So, initialise the property after component completion to ensure correct behaviour.
        Component.onCompleted: positionSource.active = Qt.binding(function() { return captureView.effectiveActive && Settings.locationEnabled && Settings.global.saveLocationInfo })
    }

    opacity: 0.0

    showCommonControls: !captureView.recording
    isPortrait: captureView.isPortrait
    topButtonRowHeight: Screen.sizeCategory >= Screen.Large ? Theme.itemSizeLarge : Theme.itemSizeSmall

    onPinchStarted: {
        // We're not getting notifications when the maximumDigitalZoom changes,
        // so update the value here.
        zoomIndicator.maximumZoom = camera.maximumDigitalZoom
    }

    onPinchUpdated: {
        camera.digitalZoom = Math.max(1, Math.min(
                    camera.digitalZoom + ((camera.maximumDigitalZoom - 1) * ((pinch.scale / Math.abs(pinch.previousScale) - 1))),
                    camera.maximumDigitalZoom))
        zoomIndicator.show()
    }

    Connections {
        target: captureView
        ignoreUnknownSignals: true
        onEffectiveActiveChanged: {
            if (!captureView.effectiveActive) {
                settingsOverlay.open = false
                settingsOverlay.inButtonLayout = false
            }
        }
    }

    onClicked: {
        if (!captureView._captureOnFocus && captureView.touchFocusSupported) {
            // Translate and rotate the touch point into focusArea's space.
            var focusPoint
            switch ((360 - captureView.viewfinderOrientation) % 360) {

            case 90:
                focusPoint = Qt.point(
                            mouse.y - ((height - focusArea.width) / 2) - captureView.viewfinderOffset,
                            width - mouse.x);
                break;
            case 180:
                focusPoint = Qt.point(
                            width - mouse.x - ((width - focusArea.width) / 2) + captureView.viewfinderOffset,
                            height - mouse.y);
                break;
            case 270:
                focusPoint = Qt.point(
                            height - mouse.y - ((height - focusArea.width) / 2) + captureView.viewfinderOffset,
                            mouse.x);
                break;
            default:
                focusPoint = Qt.point(
                            mouse.x - ((width - focusArea.width) / 2) - captureView.viewfinderOffset,
                            mouse.y);
                break;
            }

            // Normalize the focus point.
            focusPoint.x = focusPoint.x / focusArea.width
            focusPoint.y = focusPoint.y / focusArea.height

            // Mirror the point if the viewfinder is mirrored.
            if (captureView._mirrorViewfinder) {
                focusPoint.x = 1 - focusPoint.x
            }

            if (focusPoint.x >= 0.0 && focusPoint.x <= 1.0 && focusPoint.y >= 0.0 && focusPoint.y <= 1.0) {
                captureView.setFocusPoint(focusPoint)
            }
        }
    }

    shutter: CameraButton {
        id: captureButton

        z: settingsOverlay.inButtonLayout ? 1 : 0
        size: Theme.iconSizeMedium
        background.visible: icon.opacity < 1.0
        enabled: captureView._canCapture
                    && !captureView._captureOnFocus
                    && !volumeDown.pressed // avoid click + volume key release taking two pictures
                    && !volumeUp.pressed

        onPressed: camera.lockAutoFocus()
        onReleased: {
            if (containsMouse) {
                captureView._triggerCapture()
            } else {
                camera.unlockAutoFocus()
            }
        }
        onCanceled: camera.unlockAutoFocus()

        icon {
            opacity: {
                if (captureTimer.running) {
                    return 0.2
                } else if (captureButton.pressed) {
                    return 0.5
                } else {
                    return 1.0
                }
            }

            source: startRecordTimer.running || camera.videoRecorder.recorderState == CameraRecorder.RecordingState
                    ? "image://theme/icon-camera-video-shutter-off"
                    : (camera.captureMode == Camera.CaptureVideo
                       ? "image://theme/icon-camera-video-shutter-on"
                       : "image://theme/icon-camera-shutter")
        }

        Label {
            anchors.centerIn: parent
            text: captureTimer.running ? Math.floor(captureView._captureCountdown + 1) : Settings.mode.timer
            visible: Settings.mode.timer != 0
            opacity: captureTimer.running ? captureView._captureCountdown % 1 : 1.0
            color: captureTimer.running ? Theme.primaryColor : Theme.highlightDimmerColor
            font {
                pixelSize: captureTimer.running ? Theme.fontSizeHuge : Theme.fontSizeTiny
                weight: Font.Light
            }
            Behavior on font.pixelSize {
                NumberAnimation { easing.type: Easing.InOutQuad; duration: 150 }
            }
        }
    }

    Label {
        id: timerLabel

        y: Theme.paddingMedium
        anchors.horizontalCenter: parent.horizontalCenter
        opacity: captureView.recording ? 1.0 : 0.0
        Behavior on opacity { FadeAnimator {} }

        text: Format.formatDuration(_recordingDuration,
                                    _recordingDuration >= 3600 ? Formatter.DurationLong : Formatter.DurationShort)
        font.pixelSize: Theme.fontSizeLarge
        style: Text.Outline
        styleColor: "#20000000"
    }

    WallClock {
        id: clock
        updateFrequency: WallClock.Second
        enabled: camera.videoRecorder.recorderState == CameraRecorder.RecordingState
        onEnabledChanged: {
            if (enabled) {
                _startTime = clock.time
            }
        }
    }

    // Viewfinder Grid
    Item {
        id: grid

        property real gridWidth: captureView.viewfinderOrientation % 180 == 0 ? focusArea.width : focusArea.height
        property real gridHeight: captureView.viewfinderOrientation % 180 == 0 ? focusArea.height : focusArea.width
        property real ambienceScale: Math.min(Screen.width, Screen.height) /
                                     Math.max(Screen.width, Screen.height)

        anchors.centerIn: parent
        anchors.verticalCenterOffset: isPortrait ? captureView.viewfinderOffset : 0
        anchors.horizontalCenterOffset: isPortrait ? 0 : captureView.viewfinderOffset

        visible: Settings.mode.viewfinderGrid != "none"
                 && camera.cameraStatus == Camera.ActiveStatus

        width: Settings.mode.viewfinderGrid == "ambience"
               ? gridWidth * ambienceScale
               : gridWidth / 3
        height: Settings.mode.viewfinderGrid == "ambience"
                ? gridHeight * ambienceScale
                : gridHeight / 3

        GridLine {
            anchors {
                horizontalCenter: grid.horizontalCenter
                verticalCenter: grid.top
            }
            width: grid.gridWidth
        }

        GridLine {
            anchors {
                horizontalCenter: grid.horizontalCenter
                verticalCenter: grid.bottom
            }
            width: grid.gridWidth
        }

        GridLine {
            anchors {
                horizontalCenter: grid.left
                verticalCenter: grid.verticalCenter
            }
            width: grid.gridHeight
            rotation: 90
        }

        GridLine {
            anchors {
                horizontalCenter: grid.right
                verticalCenter: grid.verticalCenter
            }
            width: grid.gridHeight
            rotation: 90
        }
    }

    ZoomIndicator {
        id: zoomIndicator
        anchors {
            top: timerLabel.bottom
            horizontalCenter: parent.horizontalCenter
        }

        zoom: camera.digitalZoom
        maximumZoom: camera.maximumDigitalZoom
    }

    Notification {
        id: notification

        function publishMessage(msg) {
            notification.previewBody = msg
            notification.publish()
        }

        isTransient: true
        urgency: Notification.Critical
    }

    ConfigurationValue {
        id: previousStoragePathStatus
        key: "/apps/jolla-camera/previousStoragePathStatus"
    }
}
