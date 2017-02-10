import QtQuick 2.0
import QtMultimedia 5.0
import org.nemomobile.configuration 1.0
import com.jolla.camera 1.0

SettingsBase {
    property alias mode: modeSettings
    property alias global: globalSettings
    // mode change goes here, CaptureView updates to global.cameraDevice
    property string cameraDevice: global.cameraDevice

    readonly property var settingsDefaults: ({
                                                 "iso": 0,
                                                 "timer": 0,
                                                 "viewfinderGrid": "none",
                                                 "whiteBalance": CameraImageProcessing.WhiteBalanceAuto,
                                                 "flash": ((modeSettings.captureMode == Camera.CaptureStillImage) &&
                                                           (globalSettings.cameraDevice === "primary") ?
                                                               Camera.FlashAuto : Camera.FlashOff)
                                             })

    readonly property bool defaultSettings: modeSettings.iso === settingsDefaults["iso"] &&
                                            modeSettings.timer === settingsDefaults["timer"] &&
                                            modeSettings.viewfinderGrid === settingsDefaults["viewfinderGrid"] &&
                                            modeSettings.whiteBalance == settingsDefaults["whiteBalance"] &&
                                            modeSettings.flash == settingsDefaults["flash"]

    function reset() {
        var basePath = globalSettings.path + "/" + modeSettings.path
        for (var i in settingsDefaults) {
            _singleValue.key = basePath + "/" + i
            _singleValue.value = settingsDefaults[i]
        }
    }

    property ConfigurationValue _singleValue: ConfigurationValue {}

    property ConfigurationGroup _global: ConfigurationGroup {
        id: globalSettings

        path: "/apps/jolla-camera"

        property string cameraDevice: "primary"
        property string captureMode: "image"

        property int portraitCaptureButtonLocation: 3
        property int landscapeCaptureButtonLocation: 4

        property string audioCodec: "audio/mpeg, mpegversion=(int)4"
        property int audioSampleRate: 48000
        property string videoCodec: "video/x-h264"
        property string mediaContainer: "video/quicktime, variant=(string)iso"

        property int videoEncodingMode: CameraRecorder.AverageBitRateEncoding
        property int videoBitRate: 12000000

        property bool saveLocationInfo

        ConfigurationGroup {
            id: modeSettings
            path: globalSettings.cameraDevice + "/" + globalSettings.captureMode

            property int captureMode: Camera.CaptureStillImage

            property int iso: 0
            property int whiteBalance: CameraImageProcessing.WhiteBalanceAuto
            property int flash: Camera.FlashOff
            property int exposureCompensation: 0
            property int exposureMode: 0
            property int meteringMode: Camera.MeteringMatrix
            property int timer: 0
            property string viewfinderGrid: "none"

            property string imageResolution: "1280x720"
            property string videoResolution: "1280x720"
            property string viewfinderResolution: "1280x720"

            property var isoValues: [ 0, 100, 200, 400 ]
            property var whiteBalanceValues: [
                CameraImageProcessing.WhiteBalanceAuto,
                CameraImageProcessing.WhiteBalanceCloudy,
                CameraImageProcessing.WhiteBalanceSunlight,
                CameraImageProcessing.WhiteBalanceFluorescent,
                CameraImageProcessing.WhiteBalanceTungsten
            ]
            property var focusDistanceValues: [ Camera.FocusInfinity ]
            property var flashValues: [ Camera.FlashOff ]
            property var exposureCompensationValues: [ -4, -2, 0, 2, 4 ]
            property var exposureModeValues: [ Camera.ExposureAuto ]
            property var meteringModeValues: [
                Camera.MeteringMatrix,
                Camera.MeteringAverage,
                Camera.MeteringSpot
            ]
            property var timerValues: [ 0, 3, 5, 10, 15 ]
            property var viewfinderGridValues: [ "none", "thirds", "ambience" ]
        }
    }

    function captureModeIcon(mode) {
        switch (mode) {
        case "image": return "image://theme/icon-camera-camera-mode"
        case "video": return "image://theme/icon-camera-video"
        default:  return ""
        }
    }

    function captureModeText(mode) {
        switch (mode) {
        //: "Still image capture mode"
        //% "Camera mode"
        case "image": return qsTrId("camera_settings-la-camera-mode")
        //: "Video recording mode"
        //% "Video mode"
        case "video":      return qsTrId("camera_settings-la-video-mode")
        default:  return ""
        }
    }

    function exposureIcon(exposure) {
        // Exposure is value * 2 so it can be stored as an integer
        switch (exposure) {
        case -4: return "image://theme/icon-camera-ec-minus2"
        case -3: return "image://theme/icon-camera-ec-minus15"
        case -2: return "image://theme/icon-camera-ec-minus1"
        case -1: return "image://theme/icon-camera-ec-minus05"
        case 0:  return "image://theme/icon-camera-exposure-compensation"
        case 1:  return "image://theme/icon-camera-ec-plus05"
        case 2:  return "image://theme/icon-camera-ec-plus1"
        case 3:  return "image://theme/icon-camera-ec-plus15"
        case 4:  return "image://theme/icon-camera-ec-plus2"
        }
    }

    function timerIcon(timer) {
        return timer > 0
                ? "image://theme/icon-camera-timer-" + timer + "s"
                : "image://theme/icon-camera-timer"
    }

    function timerText(timer) {
        return timer > 0
                //% "%1 second delay"
                ? qsTrId("camera_settings-la-timer-seconds-delay").arg(timer)
                  //% "No delay"
                : qsTrId("camera_settings-la-timer-no-delay")
    }

    function isoIcon(iso) {
        return iso > 0
                ? "image://theme/icon-camera-iso-" + iso
                : "image://theme/icon-camera-iso"
    }

    function isoText(iso) {
        switch (iso) {
        //% "Light sensitivity • Automatic"
        case 0: return qsTrId("camera_settings-la-light-sensitivity-auto")
        //% "Light sensitivity • ISO 100"
        case 100: return qsTrId("camera_settings-la-light-sensitivity-100")
        //% "Light sensitivity • ISO 200"
        case 200: return qsTrId("camera_settings-la-light-sensitivity-200")
        //% "Light sensitivity • ISO 400"
        case 400: return qsTrId("camera_settings-la-light-sensitivity-400")
        //% "Light sensitivity • ISO 800"
        case 800: return qsTrId("camera_settings-la-light-sensitivity-800")
        }
    }

    function meteringModeIcon(mode) {
        switch (mode) {
        case Camera.MeteringMatrix:  return "image://theme/icon-camera-metering-matrix"
        case Camera.MeteringAverage: return "image://theme/icon-camera-metering-weighted"
        case Camera.MeteringSpot:    return "image://theme/icon-camera-metering-spot"
        }
    }

    function flashIcon(flash) {
        switch (flash) {
        case Camera.FlashAuto:              return "image://theme/icon-camera-flash-automatic"
        case Camera.FlashOff:               return "image://theme/icon-camera-flash-off"
        case Camera.FlashTorch:
        case Camera.FlashOn:                return "image://theme/icon-camera-flash-on"
        case Camera.FlashRedEyeReduction:   return "image://theme/icon-camera-flash-redeye"
        }
    }

    function flashText(flash) {
        switch (flash) {
        //: "Automatic camera flash mode"
        //% "Flash automatic"
        case Camera.FlashAuto:       return qsTrId("camera_settings-la-flash-auto")
        //: "Camera flash disabled"
        //% "Flash disabled"
        case Camera.FlashOff:   return qsTrId("camera_settings-la-flash-off")
        //: "Camera flash enabled"
        //% "Flash enabled"
        case Camera.FlashOn:      return qsTrId("camera_settings-la-flash-on")
        //: "Camera flash in torch mode"
        //% "Flash on"
        case Camera.FlashTorch:   return qsTrId("camera_settings-la-flash-torch")
        //: "Camera flash with red eye reduction"
        //% "Flash red eye"
        case Camera.FlashRedEyeReduction: return qsTrId("camera_settings-la-flash-redeye")
        }
    }

    function whiteBalanceIcon(balance) {
        switch (balance) {
        case CameraImageProcessing.WhiteBalanceAuto:        return "image://theme/icon-camera-wb-automatic"
        case CameraImageProcessing.WhiteBalanceSunlight:    return "image://theme/icon-camera-wb-sunny"
        case CameraImageProcessing.WhiteBalanceCloudy:      return "image://theme/icon-camera-wb-cloudy"
        case CameraImageProcessing.WhiteBalanceShade:       return "image://theme/icon-camera-wb-shade"
        case CameraImageProcessing.WhiteBalanceSunset:      return "image://theme/icon-camera-wb-sunset"
        case CameraImageProcessing.WhiteBalanceFluorescent: return "image://theme/icon-camera-wb-fluorecent"
        case CameraImageProcessing.WhiteBalanceTungsten:    return "image://theme/icon-camera-wb-tungsten"
        default: return "image://theme/icon-camera-wb-default"
        }
    }

    function whiteBalanceText(balance) {
        switch (balance) {
        //: "Automatic white balance"
        //% "Automatic"
        case CameraImageProcessing.WhiteBalanceAuto:        return qsTrId("camera_settings-la-wb-automatic")
        //: "Sunny white balance"
        //% "Sunny"
        case CameraImageProcessing.WhiteBalanceSunlight:    return qsTrId("camera_settings-la-wb-sunny")
        //: "Cloudy white balance"
        //% "Cloudy"
        case CameraImageProcessing.WhiteBalanceCloudy:      return qsTrId("camera_settings-la-wb-cloudy")
        //: "Shade white balance"
        //% "Shade"
        case CameraImageProcessing.WhiteBalanceShade:       return qsTrId("camera_settings-la-wb-shade")
        //: "Sunset white balance"
        //% "Sunset"
        case CameraImageProcessing.WhiteBalanceSunset:      return qsTrId("camera_settings-la-wb-sunset")
        //: "Fluorecent white balance"
        //% "Fluorecent"
        case CameraImageProcessing.WhiteBalanceFluorescent: return qsTrId("camera_settings-la-wb-fluorecent")
        //: "Tungsten white balance"
        //% "Tungsten"
        case CameraImageProcessing.WhiteBalanceTungsten:    return qsTrId("camera_settings-la-wb-tungsten")
        default: return ""
        }
    }

    function viewfinderGridIcon(grid) {
        switch (grid) {
        case "none": return "image://theme/icon-camera-grid-none"
        case "thirds": return "image://theme/icon-camera-grid-thirds"
        case "ambience": return "image://theme/icon-camera-grid-ambience"
        default: return ""
        }
    }

    function viewfinderGridText(grid) {
        switch (grid) {
        case "none": return qsTrId("No grid")
        case "thirds": return qsTrId("Thirds grid")
        case "ambience": return qsTrId("Ambience grid")
        default: return ""
        }
    }

    function cameraIcon(device) {
        return device == "primary"
                ? "image://theme/icon-camera-backcamera"
                : "image://theme/icon-camera-front-camera"
    }

    function cameraText(device) {
        return device == "primary"
                //% "Main camera"
                ? qsTrId("camera-la-main-camera")
                //% "Front camera"
                : qsTrId("camera-la-front-camera")
    }
}
