import QtQuick 2.0
import QtGraphicalEffects 1.0
import Sailfish.Silica 1.0
import ".."

ImageViewer {
    id: root

    property int baseRotation
    property int imageRotation
    property alias brightness: adjustLevels.brightness
    property alias contrast: adjustLevels.contrast
    readonly property bool longPressed: pressed && !delayPressTimer.running
    property bool animatingBrightnessContrast

    orientation: -(baseRotation + imageRotation)

    onAnimatingBrightnessContrastChanged: adjustLevels.visible = true

    function rotate(angle) {
        resetScale()
        // Don't wait for the rotation animation to complete to new image dimensions
        transposeBinding.value = (baseRotation + rotationAnimation.to + angle) % 180
        rotationAnimation.to = rotationAnimation.to + angle
        rotationAnimation.restart()
    }

    Binding {
        id: transposeBinding
        target: root
        when: rotationAnimation.running
        property: "transpose"
    }

    NumberAnimation {
        id: rotationAnimation
        target: root
        property: "imageRotation"
        easing.type: Easing.InOutQuad
        duration: 200
    }

    Behavior on _scale {
        enabled: rotationAnimation.running
        SmoothedAnimation { duration: 200 }
    }

    // On the Jolla 1, we're experiencing a crash inside the OpenGL
    // driver blob which starts when an FBO is somewhere around 2500+
    // pixels in size. Max texture size and Max renderbuffer size are
    // both 4096, well within, so the actual cause is unknown.
    property bool isJolla1: Screen.width == 540 && Screen.height == 960
    largePhoto.sourceSize {
        width: isJolla1 ? 2048 : 3264
        height: isJolla1 ? 2048 : 3264
    }

    BrightnessContrast {
        id: adjustLevels

        source: root
        visible: false
        cached: !animatingBrightnessContrast
        parent: root.parent
        width: source.width
        height: source.height
    }

    Timer {
        id: delayPressTimer
        running: pressed
        interval: 300
    }

    states: State {
        when: longPressed
        PropertyChanges {
            target: root
            brightness: 0.0
            contrast: 0.0
        }
    }
}
