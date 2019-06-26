import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.gallery.ambience 1.0

MouseArea {
    id: slider

    property real maximumValue: 1.0
    property real minimumValue: 0.0
    property real stepSize
    property real hue: 0.5
    property alias lightness: rainbow.lightness
    property alias saturation: rainbow.saturation
    property alias alpha: rainbow.alpha
    property color secondaryColor: Theme.secondaryColor
    property color highlightColor: Theme.highlightColor
    readonly property real sliderValue: Math.max(minimumValue, Math.min(maximumValue, hue))
    property bool handleVisible: true
    property alias label: labelText.text
    property bool down: pressed
    property bool highlighted: down
    property real leftMargin: Math.round(Screen.width/8)
    property real rightMargin: Math.round(Screen.width/8)

    property real _oldValue
    property bool _tracking: true
    property real _precFactor: 1.0

    property real _grooveWidth: Math.max(0, width - leftMargin - rightMargin)
    property bool _widthChanged
    property bool _cancel

    property bool _componentComplete

    onStepSizeChanged: {
        // Avoid rounding errors.  We assume that the range will
        // be sensibly related to stepSize
        var decimial = Math.floor(stepSize) - stepSize
        if (decimial < 0.001) {
            _precFactor = Math.pow(10, 7)
        } else if (decimial < 0.1) {
            _precFactor = Math.pow(10, 4)
        } else {
            _precFactor = 1.0
        }
    }

    height: handleVisible ? Theme.itemSizeExtraLarge : label !== "" ? Theme.itemSizeMedium : Theme.itemSizeSmall

    onWidthChanged: updateWidth()
    onLeftMarginChanged: updateWidth()
    onRightMarginChanged: updateWidth()

    // changing the width of the slider shouldn't animate the slider bar/handle
    function updateWidth() {
        _widthChanged = true
        _grooveWidth = Math.max(0, width - leftMargin - rightMargin)
        _widthChanged = false
    }

    function cancel() {
        _cancel = true
        hue = _oldValue
        _updateHighlightToValue()
    }

    drag {
        target: draggable
        minimumX: leftMargin - highlight.width/2
        maximumX: slider.width - leftMargin - highlight.width/2
        axis: Drag.XAxis
    }

    function _updateHighlightToValue() {
        if (maximumValue > minimumValue) {
            highlight.x = (sliderValue - minimumValue) / (maximumValue - minimumValue) * _grooveWidth - highlight.width/2 + leftMargin
        } else {
            highlight.x = leftMargin - highlight.width/2
        }
    }

    function _updateValueToDraggable() {
        if (width > (leftMargin + rightMargin)) {
            highlight.x = draggable.x
            var pos = draggable.x + highlight.width/2 - leftMargin
            hue = _calcValue((pos / _grooveWidth) * (maximumValue - minimumValue) + minimumValue)
        }
    }

    function _calcValue(newVal) {
        if (newVal <= minimumValue) {
            return minimumValue
        }

        if (stepSize > 0.0) {
            var offset = newVal - minimumValue
            var intervals = Math.round(offset / stepSize)
            newVal = Math.round((minimumValue + (intervals * stepSize)) * _precFactor) / _precFactor
        }

        if (newVal > maximumValue) {
            return maximumValue
        }

        return newVal
    }

    onPressed: {
        _cancel = false
        _oldValue = hue
        draggable.x = Math.min(Math.max(drag.minimumX, mouseX - highlight.width/2), drag.maximumX)
    }

    onReleased: {
        if (!_cancel) {
            _tracking = false
            _updateValueToDraggable()
            if (stepSize != 0.0) {
                // on release make sure that we settle on a step boundary
                _updateHighlightToValue()
            }
            _oldValue = hue
        }
    }

    onCanceled: hue = _oldValue

    onSliderValueChanged: {
        if (!slider.drag.active) {
            _tracking = false
            _updateHighlightToValue()
        }
    }

    Rectangle {
        id: background
        x: slider.leftMargin-Theme.paddingMedium
        width: slider._grooveWidth + 2*Theme.paddingMedium
        height: Theme.paddingMedium
        onWidthChanged: { _tracking = true; _updateHighlightToValue() }
        anchors.top: parent.verticalCenter

        ShaderEffect {
            id: rainbow
            property variant src: background
            property real saturation: 1.0
            property real lightness: 0.5
            property real alpha: 1.0

            width: parent.width
            height: parent.height

            // Fragment shader to create hue color wheel background
            fragmentShader: "
                varying highp vec2 coord;
                varying highp vec2 qt_TexCoord0;
                uniform sampler2D src;
                uniform lowp float qt_Opacity;
                uniform lowp float saturation;
                uniform lowp float lightness;
                uniform lowp float alpha;

                void main() {
                    lowp float r, g, b;

                    highp float h = qt_TexCoord0.x * 360.0;
                    lowp float s = saturation;
                    lowp float l = lightness;

                    lowp float c = (1.0 - abs(2.0 * l - 1.0)) * s;
                    highp float hh = h / 60.0;
                    lowp float x = c * (1.0 - abs(mod(hh, 2.0) - 1.0));

                    int i = int( hh );

                    if (i == 0) {
                        r = c; g = x; b = 0.0;
                    } else if (i == 1) {
                        r = x; g = c; b = 0.0;
                    } else if (i == 2) {
                        r = 0.0; g = c; b = x;
                    } else if (i == 3) {
                        r = 0.0; g = x; b = c;
                    } else if (i == 4) {
                        r = x; g = 0.0; b = c;
                    } else if (i == 5) {
                        r = c; g = 0.0; b = x;
                    } else {
                        r = 0.0; g = 0.0; b = 0.0;
                    }

                    lowp float m = l - 0.5 * c;

                    lowp vec4 tex = texture2D(src, qt_TexCoord0);
                    gl_FragColor = vec4(r+m,g+m,b+m,alpha) * qt_Opacity;
                }"
        }
    }

    Item {
        id: draggable
        width: highlight.width
        height: highlight.height
        onXChanged: {
            if (_cancel) {
                return
            }
            if (slider.drag.active) {
                _updateValueToDraggable()
            }
            if (!_tracking && Math.abs(highlight.x - draggable.x) < 5) {
                _tracking = true
            }
        }
    }

    GlassItem {
        id: highlight
        width: Theme.itemSizeMedium
        height: Theme.itemSizeMedium
        radius: 0.17
        falloffRadius: 0.17
        anchors {
            verticalCenter: background.verticalCenter
        }
        visible: handleVisible
        color: slider.highlighted ? slider.highlightColor : Theme.lightPrimaryColor
        Behavior on x {
            enabled: !_widthChanged
            SmoothedAnimation { velocity: 1500 }
        }
    }

    Label {
        id: labelText
        visible: text.length
        font.pixelSize: Theme.fontSizeSmall
        color: slider.highlighted ? slider.highlightColor : slider.secondaryColor
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: background.verticalCenter
        anchors.topMargin: Theme.paddingMedium
        width: Math.min(paintedWidth, parent.width - 2*Theme.paddingMedium)
        truncationMode: TruncationMode.Fade
    }

    states: State {
        name: "invalidRange"
        when: _componentComplete && minimumValue >= maximumValue
        PropertyChanges {
            target: slider
            enabled: false
            opacity: 0.6
        }
        StateChangeScript {
            script: console.log("Warning: Slider.maximumValue needs to be higher than Slider.minimumValue")
        }
    }

    Component.onCompleted: {
        _componentComplete = true
        _updateHighlightToValue()
    }
}
