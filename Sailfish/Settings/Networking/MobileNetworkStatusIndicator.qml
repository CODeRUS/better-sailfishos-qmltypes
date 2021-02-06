/****************************************************************************
**
** Copyright (c) 2013 - 2019 Jolla Ltd.
** Copyright (c) 2019 Open Mobile Platform LLC.
** License: Proprietary
**
****************************************************************************/
import QtQuick 2.6
import Sailfish.Silica 1.0
import Sailfish.Telephony 1.0
import MeeGo.QOfono 0.2

Item {
    id: root

    property string modemPath
    property var simManager
    property alias networkRegistration: networkRegistration

    property bool showMaximumStrength
    property bool showRoamingStatus
    property string iconSuffix

    property bool _simPresent: !!simManager && simManager.ready && simManager.modemHasPresentSim(modemPath)
    property bool _masked: Telephony.multiSimSupported

    function _imagePath(iconName) {
        return "image://theme/icon-status-" + iconName + iconSuffix
    }

    height: Theme.iconSizeExtraSmall
    width: signalStrengthIndicator.width * opacity

    Icon {
        anchors {
            bottom: signalStrengthIndicator.bottom
            left: signalStrengthIndicator.left
        }
        source: showRoamingStatus && networkRegistration.status === "roaming"
                ? "image://theme/icon-status-roaming" + iconSuffix
                : ""
    }

    OfonoNetworkRegistration {
        id: networkRegistration
        modemPath: root.modemPath
    }

    ShaderEffect {
        id: signalStrengthIndicator

        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
        }

        width: img.width
        height: img.height
        visible: img.source != ''

        property var source: img
        property var maskSource: mask
        property color color: palette.primaryColor

        fragmentShader: "
            varying highp vec2 qt_TexCoord0;
            uniform highp float qt_Opacity;
            uniform lowp vec4 color;
            uniform lowp sampler2D source;" + (_masked
                ? "uniform lowp sampler2D maskSource;
                   void main(void) { gl_FragColor = color * texture2D(source, qt_TexCoord0.st).a * texture2D(maskSource, qt_TexCoord0.st).a * qt_Opacity; }"
                : "void main(void) { gl_FragColor = color * texture2D(source, qt_TexCoord0.st).a * qt_Opacity; }")

        Image {
            id: img
            visible: false
            source: {
                if (root.showMaximumStrength) {
                    return root._imagePath(root._masked ? "strength-5" : "cellular-5")
                }

                if (!root._simPresent) {
                    return root._imagePath("no-sim")
                }

                switch (networkRegistration.status) {
                case "registered":
                case "roaming":
                    // convert strength to available bars icons
                    var bars = Math.floor((networkRegistration.strength + 19) / 20)
                    return root._imagePath((root._masked ? "strength-" : "cellular-") + bars)
                case "searching":
                case "unknown":
                    return root._imagePath(root._masked ? "no-cellular-masked" : "no-cellular")
                case "unregistered":
                case "denied":
                default:
                    return root._imagePath("invalid")
                }
            }
            onSourceChanged: {
                // ShaderEffect must be coaxed into changing its image
                signalStrengthIndicator.source = undefined
                signalStrengthIndicator.source = img
            }
        }

        Image {
            id: mask
            visible: false
            source: {
                if (!root.simManager || !root.simManager.ready || !root._masked) {
                    return ""
                }
                var maskBase = !root._simPresent
                        ? "image://theme/icon-status-no-sim"
                        : (networkRegistration.status === "roaming"
                           ? "image://theme/icon-status-roaming-sim"
                           : "image://theme/icon-status-cellular-sim")
                var simIndex = root.simManager.indexOfModem(root.modemPath)
                return maskBase + (simIndex + 1) + "-mask"
            }
            onSourceChanged: {
                // ShaderEffect must be coaxed into changing its image
                signalStrengthIndicator.maskSource = undefined
                signalStrengthIndicator.maskSource = _masked ? mask : undefined
            }
        }
    }
}
