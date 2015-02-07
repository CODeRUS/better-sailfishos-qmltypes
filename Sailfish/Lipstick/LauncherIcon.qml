import QtQuick 2.0
import Sailfish.Silica 1.0

Image {
    property string icon
    property bool pressed
    property real size: Theme.iconSizeLauncher

    sourceSize.width: size
    sourceSize.height: size
    width: size
    height: size
    layer.effect: pressEffectComponent
    layer.enabled: pressed

    source: {
        if (icon.indexOf(':/') !== -1 || icon.indexOf("data:image/png;base64") === 0) {
            return icon
        } else if (icon.indexOf('/') === 0) {
            return 'file://' + icon
        } else {
            return 'image://theme/' + icon
        }
    }

    Component {
        id: pressEffectComponent
        ShaderEffect {
            property variant source
            property color color: Theme.rgba(Theme.highlightBackgroundColor, 0.4)
            fragmentShader: "
            uniform sampler2D source;
            uniform highp vec4 color;
            uniform lowp float qt_Opacity;
            varying highp vec2 qt_TexCoord0;
            void main(void)
            {
                highp vec4 pixelColor = texture2D(source, qt_TexCoord0);
                gl_FragColor = vec4(mix(pixelColor.rgb/max(pixelColor.a, 0.00390625), color.rgb/max(color.a, 0.00390625), color.a) * pixelColor.a, pixelColor.a) * qt_Opacity;
            }
            "
        }
    }
}
