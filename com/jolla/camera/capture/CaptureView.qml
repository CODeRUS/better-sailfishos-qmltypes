import QtQuick 2.4
import QtMultimedia 5.4
import Sailfish.Silica 1.0
import Sailfish.Policy 1.0
import com.jolla.camera 1.0
import org.nemomobile.policy 1.0
import org.nemomobile.ngf 1.0
import org.nemomobile.dbus 2.0
import org.nemomobile.notifications 1.0
import QtSystemInfo 5.0

import "../settings"

FocusScope {
    id: captureView

    property bool active
    property int orientation
    property int effectiveIso: Settings.mode.iso
    property bool inButtonLayout: captureOverlay == null || captureOverlay.inButtonLayout
    property QtObject captureModel

    readonly property int viewfinderOrientation: {
        var rotation = 0
        switch (captureView.orientation) {
        case Orientation.Landscape: rotation = 90; break;
        case Orientation.PortraitInverted: rotation = 180; break;
        case Orientation.LandscapeInverted: rotation = 270; break;
        }

        return (720 + camera.orientation + rotation) % 360
    }
    property int captureOrientation
    property int pageRotation

    property alias camera: camera
    property QtObject viewfinder

    readonly property bool recording: active && camera.videoRecorder.recorderState == CameraRecorder.RecordingState

    property bool _complete
    property bool _unload

    property bool touchFocusSupported: (camera.focus.focusMode == Camera.FocusAuto || camera.focus.focusMode == Camera.FocusContinuous)
                                       && camera.captureMode != Camera.CaptureVideo

    // not bound to focusTimer.running, restarting timer shouldn't exit tap focus mode temporarily and lose focus state
    property bool tapFocusActive
    property bool _captureOnFocus
    property real _captureCountdown

    readonly property real viewfinderOffset: Math.min(0, isPortrait ? (focusArea.width - height)/2 : (focusArea.width - width)/2)

    readonly property bool isPortrait: orientation == Orientation.Portrait
                || orientation == Orientation.PortraitInverted
    readonly property bool effectiveActive: (active || recording) && _applicationActive

    readonly property bool _canCapture: (camera.captureMode == Camera.CaptureStillImage && camera.imageCapture.ready)
                || (camera.captureMode == Camera.CaptureVideo && camera.videoRecorder.recorderStatus >= CameraRecorder.LoadedStatus)

    property bool _captureQueued
    property bool captureBusy
    onCaptureBusyChanged: {
        if (!captureBusy && _captureQueued) {
            _captureQueued = false
            camera.captureImage()
        }
    }

    property bool handleVolumeKeys: camera.imageCapture.ready
                                    && keysResource.acquired
                                    && camera.captureMode == Camera.CaptureStillImage
                                    && !captureView._captureOnFocus
    property bool captureOnVolumeRelease

    onHandleVolumeKeysChanged: {
        if (!handleVolumeKeys)
            captureOnVolumeRelease = false
    }

    readonly property bool _mirrorViewfinder: camera.position === Camera.FrontFace
    readonly property bool _horizontalMirror: _mirrorViewfinder && camera.orientation % 180 == 0
    readonly property bool _verticalMirror: _mirrorViewfinder && camera.orientation % 180 != 0

    readonly property bool _applicationActive: Qt.application.state == Qt.ApplicationActive
    on_ApplicationActiveChanged: if (_applicationActive) flashlightServiceProbe.checkFlashlightServiceStatus()

    readonly property string cameraDevice: Settings.cameraDevice

    property var captureOverlay: null

    signal recordingStopped(url url, string mimeType)
    signal loaded
    signal captured

    Item {
        id: captureSnapshot
        property alias sourceItem: captureSnapshotEffect.sourceItem
        visible: false
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width*captureSnapshotEffect.scale
        height: parent.height*captureSnapshotEffect.scale
        ShaderEffectSource {
            id: captureSnapshotEffect
            hideSource: false
            live: false
            scale: 0.4
            anchors.centerIn: parent
            width: isPortrait ? captureView.width : captureView.height
            height: isPortrait ? captureView.height : captureView.width
            rotation: -captureView.pageRotation
        }
    }

    function reload() {
        if (captureView._complete) {
            captureView._unload = true
        }
    }

    function setFocusPoint(point) {
        focusTimer.restart()
        camera.unlock()
        tapFocusActive = true
        camera.focus.customFocusPoint = point
        camera.searchAndLock()
    }

    function _resetFocus() {
        focusTimer.running = false
        tapFocusActive = false
        camera.unlock()
    }

    function _triggerCapture() {
        captureOnVolumeRelease = false // avoid duplicate capture if volume key and some other key trigger (e.g. shutter)

        if (captureTimer.running) {
            captureTimer.reset()
        } else if (startRecordTimer.running) {
            startRecordTimer.running = false
        } else if (camera.videoRecorder.recorderState == CameraRecorder.RecordingState) {
            camera.videoRecorder.stop()
        } else if (Settings.mode.timer != 0) {
            microphoneWarningNotification.publishIfNeeded()
            captureTimer.restart()
        } else if (camera.captureMode == Camera.CaptureStillImage) {
            camera.captureImage()
        } else {
            microphoneWarningNotification.publishIfNeeded()
            camera.record()
        }
    }

    Notification {
        id: microphoneWarningNotification

        function publishIfNeeded() {
            if (camera.captureMode == Camera.CaptureVideo && !AccessPolicy.microphoneEnabled) {
                microphoneWarningNotification.publish()
            }
        }

        category: "x-nemo.general.warning"
        //: Camera audio won't be recorded, microphone disabled by Sailfish Device Manager (could be shorter translation).
        //% "Camera audio won't be recorded, microphone disabled by Sailfish Device Manager"
        previewBody: qsTrId("jolla-camera-la-microphone_disallowed_by_policy")
    }

    onEffectiveIsoChanged: {
        if (effectiveIso == 0) {
            camera.exposure.setAutoIsoSensitivity()
        } else {
            camera.exposure.manualIso = Settings.mode.iso
        }
    }

    on_CanCaptureChanged: {
        if (!_canCapture) {
            startRecordTimer.running = false
        }
    }

    Component.onCompleted: {
        flashlightServiceProbe.checkFlashlightServiceStatus()
        camera.deviceId = Settings.global.cameraDevice
        loadOverlay()
        _complete = true
    }

    onCameraDeviceChanged: {
        // We must call reload() first so camera reaches UnloadedState
        // If we switch Camera::deviceId then camera will not start again
        // which seems to be a bug in QtMultimedia
        // Qt bug: https://bugreports.qt.io/browse/QTBUG-46995
        reload()
        _resetFocus()
        captureTimer.reset()
        camera.deviceId = Settings.cameraDevice
        Settings.global.cameraDevice = Settings.cameraDevice
    }

    onEffectiveActiveChanged: {
        if (!effectiveActive) {
            _resetFocus()
            captureTimer.reset()
        }
    }

    Timer {
        // prevent video recording continuing forever in the background
        running: recording && !effectiveActive
        interval: 60*1000
        onTriggered: camera.videoRecorder.stop()
    }

    Timer {
        id: reloadTimer
        interval: 100
        running: captureView._unload && camera.cameraStatus == Camera.UnloadedStatus
        onTriggered: {
            captureView._unload = false
        }
    }

    Timer {
        id: startFailedTimer
        interval: 2000
        onTriggered: {
            if (camera.cameraStatus === Camera.StartingStatus) {
                captureView.reload()
            }
        }
    }

    NonGraphicalFeedback {
        id: shutterEvent
        event: "camera_shutter"
    }

    NonGraphicalFeedback {
        id: recordStartEvent
        event: "video_record_start"
    }

    Timer {
        id: startRecordTimer

        interval: 200
        onTriggered: {
            captureOverlay.writeMetaData()
            camera.videoRecorder.record()
            if (camera.videoRecorder.recorderState == CameraRecorder.RecordingState) {
                camera.videoRecorder.recorderStateChanged.connect(camera._finishRecording)
                extensions.disableNotifications(captureView, true)
            }
        }
    }

    SequentialAnimation {
        id: captureTimer

        property bool resetCameraOnStop

        function reset() {
            if (resetCameraOnStop) {
                _resetFocus()
                resetCameraOnStop = false
            }
            stop()
        }

        NumberAnimation {
            duration: Settings.mode.timer * 1000
            from: Settings.mode.timer
            to: 0
            easing.type: Easing.Linear
            target: captureView
            property: "_captureCountdown"
        }
        ScriptAction {
            script: {
                if (camera.captureMode == Camera.CaptureStillImage) {
                    if (camera.focusPointMode == Camera.FocusPointAuto) {
                        camera.searchAndLock()
                    }
                    camera.captureImage()
                } else {
                    camera.record()
                }

                if (captureTimer.resetCameraOnStop) {
                    _resetFocus()
                    captureTimer.resetCameraOnStop = false
                }
            }
        }
    }

    NonGraphicalFeedback {
        id: recordStopEvent
        event: "video_record_stop"
    }

    onRecordingStopped: {
        if (captureModel) {
            captureModel.appendCapture(
                        url,
                        mimeType,
                        captureOrientation,
                        camera.videoRecorder.duration / 1000,
                        camera.videoRecorder.resolution)
        }
    }

    Camera {
        id: camera

        function lockAutoFocus() {
            captureOverlay.closeMenus()
            // timed capture locks when timer triggers
            if (camera.captureMode == Camera.CaptureStillImage
                    && focus.focusMode != Camera.FocusInfinity
                    && focus.focusMode != Camera.FocusHyperfocal
                    && camera.lockStatus == Camera.Unlocked
                    && focus.focusPointMode == Camera.FocusPointAuto
                    && Settings.mode.timer == 0) {
                camera.searchAndLock()
            }
        }

        function unlockAutoFocus() {
            if (camera.captureMode == Camera.CaptureStillImage
                    && focus.focusMode != Camera.FocusInfinity
                    && focus.focusMode != Camera.FocusHyperfocal
                    && focus.focusPointMode == Camera.FocusPointAuto) {
                camera.unlock()
            }
        }

        function captureImage() {
            if (camera.lockStatus != Camera.Searching) {
                _completeCapture()
            } else {
                captureView._captureOnFocus = true
            }
        }

        function record() {
            videoRecorder.outputLocation = Settings.videoCapturePath("mp4")
            startRecordTimer.running = true
            recordStartEvent.play()
        }

        function _completeCapture() {
            if (captureBusy) {
                _captureQueued = true
                return
            }

            captureBusy = true
            captureOverlay.writeMetaData()

            shutterEvent.play()
            captureAnimation.start()

            camera.imageCapture.captureToLocation(Settings.photoCapturePath('jpg'))

            if (focusTimer.running) {
                focusTimer.restart()
            }
        }

        function _finishRecording() {
            if (videoRecorder.recorderState == CameraRecorder.StoppedState) {
                videoRecorder.recorderStateChanged.disconnect(_finishRecording)
                extensions.disableNotifications(captureView, false)
                var finalUrl = Settings.completeCapture(videoRecorder.outputLocation)
                if (finalUrl != "") {
                    captureView.recordingStopped(finalUrl, videoRecorder.mediaContainer)
                }
                recordStopEvent.play()
            }
        }

        captureMode: Settings.mode.captureMode

        onCaptureModeChanged: captureView._resetFocus()

        cameraState: captureView._complete && captureView.effectiveActive && !captureView._unload
                    ? Camera.ActiveState
                    : Camera.UnloadedState

        onCameraStateChanged: {
            if (cameraState == Camera.ActiveState && captureOverlay) {
                captureView.loaded()
            }
        }

        onCameraStatusChanged: {
            if (camera.cameraStatus == Camera.StartingStatus) {
                startFailedTimer.restart()
            } else {
                startFailedTimer.stop()
            }
        }

        imageCapture {
            resolution: Settings.mode.imageResolution
            onResolutionChanged: reload()

            onImageSaved: {
                camera.unlockAutoFocus()
                captureBusy = false

                if (captureModel) {
                    captureModel.appendCapture(
                                path,
                                "image/jpeg",
                                captureOrientation,
                                0,
                                camera.imageCapture.resolution)
                }
            }
            onCaptureFailed: {
                camera.unlockAutoFocus()
                captureBusy = false
            }
        }
        videoRecorder {
            resolution: Settings.mode.videoResolution
            onResolutionChanged: reload()
            frameRate: Settings.mode.videoFrameRate
            audioChannels: 2
            audioSampleRate: Settings.global.audioSampleRate
            audioCodec: Settings.global.audioCodec
            videoCodec: Settings.global.videoCodec
            mediaContainer: Settings.global.mediaContainer

            videoEncodingMode: Settings.global.videoEncodingMode
            videoBitRate: Settings.global.videoBitRate
        }
        focus {
            // could expect that locking focus on auto or continous behaves the same, but
            // continuous doesn't work as well
            focusMode: {
                // The cameraStatus doesn't really matter as a precondition but incorporating
                // it ensures the binding is reevaluated when the status changes and the desired
                // focus mode is assigned. Otherwise QtMultimedia may reject a mode as unsupported
                // and default to auto because the binding was evaluated in the unloaded state and
                // real support was unknown at that time.
                if (camera.cameraStatus == Camera.ActiveStatus && tapFocusActive) {
                    return Camera.FocusAuto
                } else if (Settings.mode.focusDistanceValues.indexOf(Camera.FocusContinuous) >= 0) {
                    return Camera.FocusContinuous
                } else {
                    return Settings.mode.focusDistanceValues[0]
                }
            }
            focusPointMode: tapFocusActive ? Camera.FocusPointCustom : Camera.FocusPointAuto
        }
        flash.mode: Settings.mode.flash
        imageProcessing.whiteBalanceMode: Settings.global.whiteBalance

        exposure {
            exposureMode: Settings.mode.exposureMode
            exposureCompensation: Settings.global.exposureCompensation / 2.0
            meteringMode: Settings.mode.meteringMode
        }

        viewfinder {
            resolution: Settings.mode.viewfinderResolution
            // Let gst-droid decide the best framerate
        }

        metaData {
            orientation: captureView.captureOrientation
        }

        onDeviceIdChanged: captureView.reload()
        viewfinder.onResolutionChanged: captureView.reload()
        focus.onFocusModeChanged: camera.unlock()

        onLockStatusChanged: {
            if (lockStatus != Camera.Searching && captureView._captureOnFocus) {
                captureView._captureOnFocus = false
                camera._completeCapture()
            }
        }
    }

    DeviceInfo {
        Component.onCompleted: {
            camera.metaData.cameraModel = model()
            camera.metaData.cameraManufacturer = manufacturer()
        }
    }

    CameraExtensions {
        id: extensions
    }

    Binding {
        target: captureView.viewfinder
        property: "source"
        value: camera
    }

    Binding {
        target: captureView.viewfinder
        property: "mirror"
        value: captureView._mirrorViewfinder
    }

    SequentialAnimation {
        id: captureAnimation

        PropertyAction {
            target: captureSnapshot
            property: "sourceItem"
            value: viewfinder
        }
        ScriptAction {
            script: captureSnapshotEffect.scheduleUpdate()
        }
        PropertyAction {
            target: captureSnapshot
            property: "x"
            value: 0
        }
        PropertyAction {
            target: captureSnapshot
            property: "visible"
            value: true
        }
        PropertyAction {
            target: viewfinder
            property: "opacity"
            value: 0
        }
        PauseAnimation {
            duration: 100
        }
        ParallelAnimation {
            XAnimator {
                target: captureSnapshot
                from: 0
                to: captureView.isPortrait ? -captureView.height : -captureView.width
                duration: 300
                easing.type: Easing.InQuad
            }
            OpacityAnimator {
                target: viewfinder
                to: 1
                duration: 300
            }
        }
        PropertyAction {
            target: captureSnapshot
            property: "visible"
            value: false
        }
        PropertyAction {
            target: captureSnapshot
            property: "sourceItem"
            value: null
        }
        ScriptAction {
            script: captureView.captured()
        }
    }

    property Component overlayComponent
    property var overlayIncubator

    function loadOverlay() {
        overlayComponent = Qt.createComponent("CaptureOverlay.qml", Component.Asynchronous, captureView)
        if (overlayComponent) {
            if (overlayComponent.status === Component.Ready) {
                incubateOverlay()
            } else if (overlayComponent.status === Component.Loading) {
                overlayComponent.statusChanged.connect(
                    function(status) {
                        if (overlayComponent) {
                            if (status == Component.Ready) {
                                incubateOverlay()
                            } else if (status == Component.Error) {
                                console.warn(overlayComponent.errorString())
                            }
                        }
                    })
            } else {
                console.log("Error loading capture overlay", overlayComponent.errorString())
            }
        }
    }

    function incubateOverlay() {
        overlayIncubator = overlayComponent.incubateObject(captureView, {
                                                                      "captureView": captureView,
                                                                      "camera": camera,
                                                                      "focusArea": focusArea
                                                                  }, Qt.Asynchronous)
        overlayIncubator.onStatusChanged = function(status) {
            if (status == Component.Ready) {
                captureOverlay = overlayIncubator.object
                overlayFadeIn.start()
                overlayIncubator = null
                if (camera.cameraState == Camera.ActiveState && captureOverlay) {
                    captureView.loaded()
                }
            } else if (status == Component.Error) {
                console.log("Failed to create capture overlay")
                overlayIncubator = null
            }
        }
    }

    FadeAnimator {
        id: overlayFadeIn
        target: captureOverlay
        to: 1.0
        duration: 100
    }

    Item {
        id: focusArea

        width: Screen.width
               * camera.viewfinder.resolution.width
               / camera.viewfinder.resolution.height
        height: Screen.width

        rotation: -captureView.viewfinderOrientation
        anchors {
            centerIn: parent
            verticalCenterOffset: isPortrait ? viewfinderOffset : 0
            horizontalCenterOffset: isPortrait ? 0 : viewfinderOffset
        }
        opacity: captureOverlay ? 1.0 - captureOverlay.settingsOpacity : 1.0

        Repeater {
            model: camera.focus.focusZones
            delegate: Item {
                x: focusArea.width * (captureView._horizontalMirror
                                      ? 1 - area.x - area.width
                                      : area.x)
                y: focusArea.height * (captureView._verticalMirror
                                      ? 1 - area.y - area.height
                                      : area.y)
                width: focusArea.width * area.width
                height: focusArea.height * area.height

                visible: status != Camera.FocusAreaUnused && camera.focus.focusPointMode == Camera.FocusPointCustom

                Rectangle {
                    id: focusRectangle

                    width: Math.min(parent.width, parent.height)
                    height: width
                    anchors.centerIn: parent
                    radius: width / 2
                    border {
                        width: Math.round(Theme.pixelRatio * 2)
                        color: status == Camera.FocusAreaFocused
                               ? (Theme.colorScheme == Theme.LightOnDark
                                  ? Theme.highlightColor : Theme.highlightFromColor(Theme.highlightColor, Theme.LightOnDark))
                               : "white"
                    }
                    color: "#00000000"
                }
            }
        }
    }

    Timer {
        id: focusTimer

        interval: 5000
        onTriggered: {
            if (!captureTimer.running) {
                captureView._resetFocus()
            } else {
                captureTimer.resetCameraOnStop = true
            }
        }
    }

    Keys.onVolumeDownPressed: {
        if (handleVolumeKeys && !event.isAutoRepeat) {
            camera.lockAutoFocus()
            captureOnVolumeRelease = true
        }
    }
    Keys.onVolumeUpPressed: {
        if (handleVolumeKeys && !event.isAutoRepeat) {
            camera.lockAutoFocus()
            captureOnVolumeRelease = true
        }
    }

    function supportedKey(key) {
        return key === Qt.Key_CameraFocus
                || key === Qt.Key_Camera
                || key === Qt.Key_VolumeDown
                || key === Qt.Key_VolumeUp
    }

    Keys.onPressed: {
        if (supportedKey(event.key)) {
            event.accepted = true
        }

        if (event.isAutoRepeat) {
            return
        }

        if (event.key == Qt.Key_CameraFocus) {
            camera.lockAutoFocus()
        } else if (event.key == Qt.Key_Camera) {
            captureView._triggerCapture() // key having half-pressed state too so can capture already here
        }
    }

    Keys.onReleased: {
        if (supportedKey(event.key)) {
            event.accepted = true
        }

        if (event.isAutoRepeat) {
            return
        }

        if (event.key == Qt.Key_CameraFocus) {
            // note: forces capture if it was still pending. debatable if that should be allowed to finish.
            camera.unlockAutoFocus()
        } else if ((event.key == Qt.Key_VolumeDown || event.key == Qt.Key_VolumeUp)
                   && captureOnVolumeRelease && handleVolumeKeys) {
            captureView._triggerCapture()
        }
    }

    Permissions {
        enabled: captureView.activeFocus
                    && camera.captureMode == Camera.CaptureStillImage
                    && camera.cameraState == Camera.ActiveState
        autoRelease: true
        applicationClass: "camera"

        Resource {
            id: keysResource
            type: Resource.ScaleButton
            optional: true
        }
    }

    Permissions {
        enabled: Qt.application.state == Qt.ApplicationActive
        autoRelease: true
        applicationClass: "camera"

        Resource {
            type: Resource.SnapButton
            optional: true
        }
    }

    DBusInterface {
        id: flashlightServiceProbe
        service: "org.freedesktop.DBus"
        path: "/org/freedesktop/DBus"
        iface: "org.freedesktop.DBus"
        property bool flashlightServiceActive
        onFlashlightServiceActiveChanged: {
            if (flashlightServiceActive) {
                if (flashlightComponentLoader.sourceComponent == null || flashlightComponentLoader.sourceComponent == undefined) {
                    flashlightComponentLoader.sourceComponent = flashlightComponent
                } else {
                    flashlightComponentLoader.item.toggleFlashlight()
                }
            }
        }
        function checkFlashlightServiceStatus() {
            var probe = flashlightServiceProbe // cache id resolution to avoid context destruction issues
            typedCall('NameHasOwner',
                      { 'type': 's', 'value': 'com.jolla.settings.system.flashlight' },
                        function(result) { probe.flashlightServiceActive = false; probe.flashlightServiceActive = result }, // twiddle so that the change-handler is invoked
                        function() { probe.flashlightServiceActive = false; probe.flashlightServiceActive = true })         // assume true in failed case, to ensure we turn it off
        }
    }

    Loader { id: flashlightComponentLoader }

    Component {
        id: flashlightComponent
        DBusInterface {
            id: flashlightDbus
            bus: DBusInterface.SessionBus
            service: "com.jolla.settings.system.flashlight"
            path: "/com/jolla/settings/system/flashlight"
            iface: "com.jolla.settings.system.flashlight"
            Component.onCompleted: toggleFlashlight()
            function toggleFlashlight() {
                var isOn = flashlightDbus.getProperty("flashlightOn")
                if (isOn) flashlightDbus.call("toggleFlashlight")
            }
        }
    }
}
