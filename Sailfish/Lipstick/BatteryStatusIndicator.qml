/****************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Vesa Halttunen <vesa.halttunen@jollamobile.com>
**
****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.systemsettings 1.0
import Nemo.Mce 1.0

SilicaItem {
    id: batteryStatusIndicator

    property string iconSuffix
    property alias icon: batteryStatusIndicatorImage.source
    property alias text: batteryStatusIndicatorText.text
    property alias color: batteryStatusIndicatorText.color
    property real totalHeight: height
    property bool usbPreparingMode

    height: Theme.iconSizeExtraSmall
    width: batteryStatusIndicatorText.x+batteryStatusIndicatorText.width

    BatteryStatus {
        id: batteryStatus
    }
    McePowerSaveMode {
        id: mcePowerSaveMode
    }

    readonly property bool isCharging: batteryStatus.chargerStatus == BatteryStatus.Connected

    Icon {
        id: chargeItem
        anchors.verticalCenter: parent.verticalCenter
        height: chargeCableIcon.height
        width: chargeCableIcon.width + chargeCableIcon.x
        clip: chargeCableAnim.running
        Image {
            id: chargeCableIcon
            source: "image://theme/icon-status-charge-cable" + iconSuffix
            anchors.verticalCenter: parent.verticalCenter
            visible: isCharging || chargeCableAnim.running
            x: isCharging ? 0 : -width
            Behavior on x { NumberAnimation { id: chargeCableAnim; duration: 500; easing.type: Easing.InOutQuad } }
        }

        layer.enabled: usbPreparingMode
        layer.effect: ShaderEffect {
            property real pulse
            NumberAnimation on pulse {
                running: chargeItem.layer.enabled && chargeCableIcon.visible
                loops: Animation.Infinite
                from: 0.0
                to: 1.0
                duration: 1000
            }

            fragmentShader: "
                uniform sampler2D source;
                varying mediump vec2 qt_TexCoord0;
                uniform lowp float qt_Opacity;
                uniform mediump float pulse;
                const lowp float width = 0.2;
                const lowp float start = 0.0;
                // The end value is calculated from the SVG coordinates so that
                // the pulse stops at the cable connector
                const lowp float end = 16.816 / 24.0;
                const lowp float wavelength = 1.0;
                void main() {
                    lowp vec4 col = texture2D(source, qt_TexCoord0);
                    if ((mod(qt_TexCoord0.x - pulse, wavelength) < width)
                        && (qt_TexCoord0.x >= start) && (qt_TexCoord0.x < end)) {
                        col.rgba = vec4(0.0);
                    }
                    gl_FragColor = col * qt_Opacity;
                    return;
                }
            "
        }
    }

    Icon {
        id: batteryStatusIndicatorImage
        anchors.verticalCenter: parent.verticalCenter
        x: Math.max(chargeItem.width, Theme.paddingMedium)
        source: sourceValue

        readonly property bool baseNameEquals: sourceValue.indexOf(source) === 0 || source.toString().indexOf(sourceValue) === 0
        property string sourceValue: {
            var name = "battery"
            if (isCharging) {
                name = "charge"
            } else if (batteryStatus.status == BatteryStatus.Low || batteryStatus.status == BatteryStatus.Empty) {
                name = "battery-warning"
            } else if (mcePowerSaveMode.active) {
                name = "powersave"
            }
            return ["image://theme/icon-status-", name, iconSuffix].join("")
        }

        // delay updating state to coincide with cable animation touching the indicator
        onSourceValueChanged: statusChangeTimer.restart()

        Timer {
            id: statusChangeTimer
            interval: batteryStatusIndicatorImage.baseNameEquals ? 0 : chargeCableAnim.duration/2
            onTriggered: batteryStatusIndicatorImage.source = batteryStatusIndicatorImage.sourceValue
        }
    }

    Text {
        id: batteryStatusIndicatorText
        anchors {
            left: batteryStatusIndicatorImage.right
            leftMargin: Theme.paddingSmall
            verticalCenter: parent.verticalCenter
        }

        font {
            family: Theme.fontFamilyHeading
            pixelSize: Theme.fontSizeSmall
        }
        text: batteryStatus.chargePercentage < 0 ? "" : batteryStatus.chargePercentage + "%"
        color: batteryStatusIndicator.palette.primaryColor
    }
}
