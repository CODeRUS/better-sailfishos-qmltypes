import QtQuick 2.0
import QtMultimedia 5.0
import org.nemomobile.configuration 1.0
import com.jolla.camera 1.0

SettingsBase {
    property alias mode: modeSettings
    property alias global: globalSettings
    // mode change goes here, CaptureView updates to global.cameraDevice
    property string cameraDevice: global.cameraDevice

    readonly property var globalDefaults: ({
                                               "iso": 0
                                           })

    readonly property var settingsDefaults: ({
                                                 "timer": 0,
                                                 "viewfinderGrid": "none",
                                                 "flash": ((modeSettings.captureMode == Camera.CaptureStillImage) &&
                                                           (globalSettings.cameraDevice === "primary") ?
                                                               Camera.FlashAuto : Camera.FlashOff)
                                             })

    readonly property bool defaultSettings: globalSettings.iso === settingsDefaults["iso"] &&
                                            modeSettings.timer === settingsDefaults["timer"] &&
                                            modeSettings.viewfinderGrid === settingsDefaults["viewfinderGrid"] &&
                                            modeSettings.flash == settingsDefaults["flash"]

    function reset() {
        var basePath = globalSettings.path + "/" + modeSettings.path
        var i
        for (i in settingsDefaults) {
            _singleValue.key = basePath + "/" + i
            _singleValue.value = settingsDefaults[i]
        }

        basePath = globalSettings.path
        for (i in globalDefaults) {
            _singleValue.key = basePath + "/" + i
            _singleValue.value = globalDefaults[i]
        }
    }

    property ConfigurationValue _singleValue: ConfigurationValue {}

    property ConfigurationGroup _global: ConfigurationGroup {
        id: globalSettings

        path: "/apps/jolla-camera"

        // Note! don't touch this for changing between cameras, see cameraDevice on root
        property string cameraDevice: "primary"
        property string captureMode: "image"

        property int portraitCaptureButtonLocation: 3
        property int landscapeCaptureButtonLocation: 5

        property string audioCodec: "audio/mpeg, mpegversion=(int)4"
        property int audioSampleRate: 48000
        property string videoCodec: "video/x-h264"
        property string mediaContainer: "video/quicktime, variant=(string)iso"

        property int videoEncodingMode: CameraRecorder.AverageBitRateEncoding
        property int videoBitRate: 12000000

        property bool saveLocationInfo

        property int iso: 0
        property int exposureCompensation: 0
        property int whiteBalance: CameraImageProcessing.WhiteBalanceAuto

        property var isoValues: [ 0, 100, 200, 400 ]
        property var exposureCompensationValues: [ 4, 3, 2, 1, 0, -1, -2, -3, -4 ]
        property var whiteBalanceValues: [
            CameraImageProcessing.WhiteBalanceAuto,
            CameraImageProcessing.WhiteBalanceCloudy,
            CameraImageProcessing.WhiteBalanceSunlight,
            CameraImageProcessing.WhiteBalanceFluorescent,
            CameraImageProcessing.WhiteBalanceTungsten
        ]

        ConfigurationGroup {
            id: modeSettings
            path: globalSettings.cameraDevice + "/" + globalSettings.captureMode

            property int captureMode: Camera.CaptureStillImage

            property int flash: Camera.FlashOff
            property int exposureMode: 0
            property int meteringMode: Camera.MeteringMatrix
            property int timer: 0
            property string viewfinderGrid: "none"

            property string imageResolution: "1280x720"
            property string videoResolution: "1280x720"
            property string viewfinderResolution: "1280x720"

            property var focusDistanceValues: [ Camera.FocusInfinity ]
            property var flashValues: [ Camera.FlashOff ]
            property var exposureModeValues: [ Camera.ExposureAuto ]
            property var meteringModeValues: [
                Camera.MeteringMatrix,
                Camera.MeteringAverage,
                Camera.MeteringSpot
            ]
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

    function exposureText(exposure) {
        switch (exposure) {
        case -4: return "-2"
        case -3: return "-1.5"
        case -2: return "-1"
        case -1: return "-0.5"
        case 0:  return ""
        case 1:  return "+0.5"
        case 2:  return "+1"
        case 3:  return "+1.5"
        case 4:  return "+2"
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
        case "none":
            //% "No grid"
            return qsTrId("camera_settings-la-no_grid")
        case "thirds":
            //% "Thirds grid"
            return qsTrId("camera_settings-la-thirds_grid")
        case "ambience":
            //% "Ambience grid"
            return qsTrId("camera_settings-la-ambience_grid")
        default: return ""
        }
    }
}
