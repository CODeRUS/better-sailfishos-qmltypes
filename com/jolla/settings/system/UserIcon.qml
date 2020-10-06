/*
 * Copyright (c) 2020 Open Mobile Platform LLC.
 *
 * License: Proprietary
 */

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.AccessControl 1.0
import org.nemomobile.systemsettings 1.0

Image {
    id: icon

    property color color: highlighted ? highlightColor : userColor
    property color highlightColor: Theme.highlightColor
    property bool highlighted
    property int type
    property int uid
    property var userColors: ["cc6600", "cccc00", "00cc00", "0000cc", "cc00cc", "0099cc", "00cc99"]
    // systemUserUid is assumed to be the smallest possible uid
    property color userColor: {
        if (type === UserModel.Guest) {
            return Theme.colorScheme === Theme.LightOnDark ? "#FFFFFF" : "#000000"
        } else {
            return "#" + userColors[(uid - AccessControl.systemUserUid()) % userColors.length]
        }
    }

    source: {
        if (type === UserModel.Guest) {
            return "image://theme/icon-m-contact"
        }
        var file = "image://theme/icon-m-user"
        if (type === UserModel.DeviceOwner) {
            file = file + "-admin"
        }
        return file + (Theme.colorScheme === Theme.LightOnDark ? "-light" : "-dark")
    }
    layer.enabled: true
    layer.effect: ShaderEffect {
        property color color: icon.color
        property bool monochrome: icon.highlighted || icon.type === UserModel.Guest

        fragmentShader: "
            uniform sampler2D source;
            uniform lowp float qt_Opacity;
            uniform highp vec4 color;
            uniform bool monochrome;
            varying highp vec2 qt_TexCoord0;
            void main() {
                highp vec4 tx = texture2D(source, qt_TexCoord0);
                if (monochrome)
                    tx = vec4(0.0, tx.aaa);
                gl_FragColor = vec4((color.rgb * tx.z) + tx.xxx, tx.y) * qt_Opacity;
            }"
    }
}
