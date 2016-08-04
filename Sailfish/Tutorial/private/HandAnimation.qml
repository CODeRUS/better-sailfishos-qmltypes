import QtQuick 2.0
import Sailfish.Silica 1.0

SequentialAnimation {
    id: root

    property Item hand
    property Item zoomItem
    property real zoomedOutScale

    signal pressed
    signal released

    ScriptAction  {
        script: {
            hand.opacity = 0
            hand.thumb.rotation = 0
            hand.thumb.yOffset = hand.thumb.initialYOffset
            hand.pressCircle.opacity = 0
            hand.pressCircle.scale = hand.pressCircle.reducedScale
        }
    }
    NumberAnimation {
        target: zoomItem
        property: "scale"
        to: zoomedOutScale
        duration: 300
        easing.type: Easing.OutQuad
    }
    SequentialAnimation {
        FadeAnimation {
            target: hand
            to: 1
            duration: 350
            easing.type: Easing.OutQuad
        }
        PauseAnimation { duration: 600 }
        ParallelAnimation {
            RotationAnimation {
                target: hand.thumb
                property: "rotation"
                to: hand.pressRotate
                duration: 250
                easing.type: Easing.OutQuad
            }
            NumberAnimation {
                target: hand.thumb
                property: "yOffset"
                to: hand.thumb.initialYOffset + hand.pressTranslate
                duration: 250
                easing.type: Easing.OutQuad
            }
            SequentialAnimation {
                PauseAnimation { duration: 150 }
                ParallelAnimation {
                    ScriptAction { script: { root.pressed() } }
                    FadeAnimation {
                        target: hand.pressCircle
                        to: 1
                        duration: 250
                        easing.type: Easing.OutQuad
                    }
                    SequentialAnimation {
                        PauseAnimation { duration: 100 }
                        NumberAnimation {
                            target: hand.pressCircle
                            property: "scale"
                            to: 1
                            duration: 250
                            easing.type: Easing.OutQuad
                        }
                    }
                }
            }
        }
        PauseAnimation { duration: 500 }
        ParallelAnimation {
            RotationAnimation {
                target: hand.thumb
                property: "rotation"
                to: hand.dragRotate + hand.pressRotate
                duration: 2000
                easing.type: Easing.InOutQuad
            }
            NumberAnimation {
                target: hand.thumb
                property: "yOffset"
                to: hand.thumb.initialYOffset + hand.dragTranslate + hand.pressTranslate
                duration: 2000
                easing.type: Easing.InOutQuad
            }
        }
        PauseAnimation { duration: 200 }
        ScriptAction { script: { root.released() } }
        ParallelAnimation {
            RotationAnimation {
                target: hand.thumb
                property: "rotation"
                to: hand.dragRotate
                duration: 250
                easing.type: Easing.InQuad
            }
            NumberAnimation {
                target: hand.thumb
                property: "yOffset"
                to: hand.thumb.initialYOffset + hand.dragTranslate
                duration: 250
                easing.type: Easing.InQuad
            }
            SequentialAnimation {
                PauseAnimation { duration: 150 }
                ParallelAnimation {
                    NumberAnimation {
                        target: hand.pressCircle
                        property: "scale"
                        to: hand.pressCircle.reducedScale
                        duration: 250
                        easing.type: Easing.InQuad
                    }
                    SequentialAnimation {
                        PauseAnimation { duration: 100 }
                        FadeAnimation {
                            target: hand.pressCircle
                            to: 0
                            duration: 250
                            easing.type: Easing.InQuad
                        }
                    }
                }
            }
        }
    }
    FadeAnimation {
        target: hand
        to: 0
        duration: 350
    }
    PauseAnimation { duration: 650 }
    NumberAnimation {
        target: zoomItem
        property: "scale"
        to: 1.0
        duration: 300
        easing.type: Easing.OutQuad
    }
}
