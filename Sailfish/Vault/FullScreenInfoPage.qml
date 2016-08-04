import QtQuick 2.2
import Sailfish.Silica 1.0

Page {
    property alias topText: topLabel.text
    property alias bottomSmallText: bottomSmallLabel.text
    property alias bottomLargeText: bottomLargeLabel.text
    property alias button1Text: button1.text
    property alias button2Text: button2.text

    property alias centerSection: centerItem
    property alias bottomSection: bottomItem

    property alias showProgress: progressCircle.visible
    property alias progressValue: progressCircle.value
    property alias progressImageSource: progressImage.source
    property alias progressCaption: progressCaptionLabel.text
    property bool animateLabelOpacity

    signal button1Clicked()
    signal button2Clicked()

    backNavigation: false

    Rectangle {
        anchors.fill: parent
        color: "black"
    }

    Item {
        id: topItem
        width: parent.width
        height: parent.height/3

        Label {
            id: topLabel
            x: Theme.horizontalPageMargin
            width: parent.width - x*2
            anchors.centerIn: parent
            horizontalAlignment: Text.AlignHCenter

            font.family: Theme.fontFamilyHeading
            font.pixelSize: Theme.fontSizeExtraLarge
            wrapMode: Text.WordWrap
            color: Theme.highlightColor
        }
    }

    Item {
        id: centerItem
        width: parent.width
        height: parent.height/3
        y: topItem.height

        ProgressCircle {
            id: progressCircle
            anchors.horizontalCenter: parent.horizontalCenter
            y: Theme.paddingLarge
            width: height
            height: parent.height
                    - progressCaptionLabel.implicitHeight
                    - progressCaptionLabel.anchors.topMargin
                    - Theme.paddingLarge*2
            progressColor: Theme.highlightColor
            backgroundColor: Theme.highlightDimmerColor

            Behavior on value { NumberAnimation {} }

            Image {
                id: progressImage
                anchors.centerIn: parent
            }
        }

        Label {
            id: progressCaptionLabel
            anchors.top: progressCircle.bottom
            anchors.topMargin: Theme.paddingLarge
            x: Theme.horizontalPageMargin
            width: parent.width - x*2
            visible: text.length > 0
            horizontalAlignment: Text.AlignHCenter

            font.pixelSize: Theme.fontSizeSmall
            wrapMode: Text.WordWrap
            color: Theme.highlightColor
        }
    }

    onAnimateLabelOpacityChanged: {
        if (!animateLabelOpacity) {
            opacityAnim.stop()
            bottomSmallLabel.opacity = 1
        }
    }

    Item {
        id: bottomItem
        y: parent.height - height
        width: parent.width
        height: parent.height / 3

        Column {
            width: parent.width
            anchors.centerIn: parent
            spacing: Theme.paddingLarge

            Label {
                id: bottomSmallLabel
                x: Theme.horizontalPageMargin
                width: parent.width - x*2
                height: implicitHeight + Theme.paddingLarge
                horizontalAlignment: Text.AlignHCenter

                visible: text.length > 0
                font.pixelSize: Theme.fontSizeMedium
                wrapMode: Text.Wrap
                color: Theme.highlightColor

                onTextChanged: {
                    // If the same text is shown for more than 1 second, animate it.
                    // When the animation is stopped, fade in the text to avoid an abrupt opacity=1.
                    if (text.length > 0) {
                        opacityAnim.stop()
                        fadeIn.start()
                        delayedOpacityAnim.restart()
                    } else {
                        opacityAnim.stop()
                        fadeIn.start()
                    }
                }

                Timer {
                    id: delayedOpacityAnim
                    interval: 1000
                    onTriggered: {
                        if (root.animateLabelOpacity) {
                            opacityAnim.start()
                        }
                    }
                }

                SequentialAnimation on opacity {
                    id: opacityAnim
                    running: false
                    loops: Animation.Infinite
                    OpacityAnimator { from: 1; to: 0; duration: 2000 }
                    OpacityAnimator { from: 0; to: 1; duration: 2000 }
                }

                FadeAnimator {
                    id: fadeIn
                    to: 1
                }
            }

            Label {
                id: bottomLargeLabel
                x: Theme.horizontalPageMargin
                width: parent.width - x*2
                height: implicitHeight + Theme.paddingLarge
                horizontalAlignment: Text.AlignHCenter

                visible: text.length > 0
                font.family: Theme.fontFamilyHeading
                font.pixelSize: Theme.fontSizeExtraLarge
                wrapMode: Text.WordWrap
                color: Theme.highlightColor
            }

            Button {
                id: button1
                anchors.horizontalCenter: parent.horizontalCenter
                visible: text.length > 0
                onClicked: root.button1Clicked()
            }

            Button {
                id: button2
                anchors.horizontalCenter: parent.horizontalCenter
                visible: text.length > 0
                onClicked: root.button2Clicked()
            }
        }
    }
}
