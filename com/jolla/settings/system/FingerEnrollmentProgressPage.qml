import QtQuick 2.2
import Sailfish.Silica 1.0
import com.jolla.settings.system 1.0
import org.nemomobile.devicelock 1.0


FingerEnrollmentPage {
    id: page

    property bool _failed
    property bool _finished

    canAccept: _finished
    canNavigateForward: _finished

    forwardNavigation: _finished
    backNavigation: _failed || !_finished

    header.acceptText: {
        if (page._failed) {
            //% "Retry"
            return qsTrId("settings_devicelock-la-retry")
        } else if (page._finished) {
            //: Next page
            //% "Next"
            return qsTrId("settings_devicelock-he-next_page")
        } else {
            return ""
        }
    }

    instruction: {
        if (_failed) {
            //% "Error! Your fingerprint could not be captured"
            return qsTrId("settings_devicelock-la-fingerprint_failed_instruction")
        } else if (_finished) {
            //% "Ready! Your fingerprint can be used for unlocking your device"
            return qsTrId("settings_devicelock-la-fingerprint_complete_instruction")
        } else {
            //% "Place and lift your finger on the fingerprint sensor repeatedly"
            return qsTrId("settings_devicelock-la-fingerprint_progress_instruction")
        }
    }

    onStatusChanged: {
        if (status == PageStatus.Active && !settings.acquiring && !_finished) {
            page.settings.acquireFinger(page.authenticationToken)
        }
    }

    Connections {
        target: page.settings
        onAcquisitionCompleted: {
            page._finished = true

            page.acceptDestination = page.destination
            page.acceptDestinationAction = PageStackAction.Replace
        }
        onAcquisitionFeedback: {
            switch (feedback) {
            case FingerprintSensor.PartialPrint:
                //% "Place and lift your finger again"
                page.feedback = qsTrId("settings_devicelock-la-fingerprint_feedback_partial_print_explanation")
                break;
            case FingerprintSensor.PrintIsUnclear:
                //% "Touch the fingerprint sensor a bit harder"
                page.feedback = qsTrId("settings_devicelock-la-fingerprint_feedback_print_unclear_explanation")
                break
            case FingerprintSensor.SensorIsDirty:
                //% "Wipe the sensor to clear any grime that might be obstructing it"
                page.feedback = qsTrId("settings_devicelock-la-fingerprint_feedback_sensor_is_dirty_explanation")
                break
            case FingerprintSensor.SwipeFaster:
                //% "Swipe the fingerprint sensor a bit faster"
                page.feedback = qsTrId("settings_devicelock-la-fingerprint_feedback_swipe_faster_explanation")
                break;
            case FingerprintSensor.SwipeSlower:
                //% "Swipe the fingerprint sensor a bit slower"
                page.feedback = qsTrId("settings_devicelock-la-fingerprint_feedback_swipe_slower_explanation")
                break;
            default:
                break
            }
        }
        onAcquisitionError: {
            if (page.status != PageStatus.Active && page.status != PageStatus.Activating) {
                // Not the active page, do nothing.
                return;
            }

            page._failed = true
            page._finished = true

            page.acceptDestination = Qt.resolvedUrl("FingerEnrollmentProgressPage.qml")
            page.acceptDestinationAction = PageStackAction.Replace

            switch (error) {
            case FingerprintSensor.Canceled:
                return  // Should have received some feeback prior to this pushing the feedback page.
            case FingerprintSensor.HardwareUnavailable:
                //% "The hardware is reporting an error and fingerprint acquisition cannot continue"
                page.explanation = qsTrId("settings_devicelock-la-fingerprint_error_hardware_unavailable_explanation")
                break
            case FingerprintSensor.CannotContinue:
                //% "An internal error has occurred or data is corrupted and fingerprint acquisition cannot continue"
                page.explanation = qsTrId("settings_devicelock-la-fingerprint_error_cannot_continue_explanation")
                break
            case FingerprintSensor.Timeout:
                //% "Fingerprint acquisition has timed out waiting for input"
                page.explanation = qsTrId("settings_devicelock-la-fingerprint_error_timeout_explanation")
                break
            case FingerprintSensor.NoSpace:
                //% "There is insufficient storage space to save the fingerprint"
                page.explanation = qsTrId("settings_devicelock-la-fingerprint_error_no_space_explanation")
                break;
            default:
                break
            }
            page.feedback = ""
        }
        onSamplesRemainingChanged: {
            if (!page._failed) {
                page.feedback = ""
            }
        }
    }

    ShaderEffect {

        property variant fingerprint: Image {
            id: fingerprintGraphic

            parent: page

            source: "image://theme/graphic-fingerprint"
            visible: false
        }

        property point circleScale: {
            if (fingerprintGraphic.width == 0 || fingerprintGraphic.height == 0) {
                return Qt.point(2, 2)
            } else if (fingerprintGraphic.width > fingerprintGraphic.height) {
                return Qt.point(2, 2 * fingerprintGraphic.height / fingerprintGraphic.width)
            } else {
                return Qt.point(2 * fingerprintGraphic.width / fingerprintGraphic.height, 2)
            }
        }


        function square(number) {
            return number * number
        }

        property real progress: {
            if (page._finished && !page._failed) {
                return 1
            } else if (page.settings.acquiring && page.settings.samplesRequired > 0) {
                return square(Math.max(0, page.settings.samplesRequired - page.settings.samplesRemaining)
                    / (page.settings.samplesRequired))
            } else {
                return 0
            }
        }

        Behavior on progress { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }

        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
            verticalCenterOffset: Theme.itemSizeExtraSmall
        }

        width: fingerprintGraphic.width
        height: fingerprintGraphic.height

        vertexShader: "
            uniform highp vec2 circleScale;
            uniform highp mat4 qt_Matrix;
            attribute highp vec4 qt_Vertex;
            attribute highp vec2 qt_MultiTexCoord0;
            varying highp vec2 uv;
            varying highp vec2 distance;

            void main() {
                uv = qt_MultiTexCoord0;
                distance = (qt_MultiTexCoord0 - vec2(0.5, 0.5)) * circleScale;
                gl_Position = qt_Matrix * qt_Vertex;
            }
"

        fragmentShader: "
            uniform sampler2D fingerprint;
            uniform highp float progress;
            uniform lowp float qt_Opacity;
            varying highp vec2 uv;
            varying highp vec2 distance;

            void main() {
                lowp vec4 tx = texture2D(fingerprint, uv);
                lowp float fade = 0.35 + (0.65 * step(dot(distance, distance), progress));
                gl_FragColor = tx * qt_Opacity * fade;
            }
"
    }
}
