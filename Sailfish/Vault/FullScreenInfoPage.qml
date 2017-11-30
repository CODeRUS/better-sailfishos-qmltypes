import QtQuick 2.2
import Sailfish.Silica 1.0

Page {
    id: root

    property alias topText: topLabel.text
    property alias topSmallText: topSmallLabel.text
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

    onAnimateLabelOpacityChanged: {
        if (!animateLabelOpacity) {
            opacityAnim.stop()
            bottomSmallLabel.opacity = 1
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.overlayBackgroundColor
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: contentColumn.height

        VerticalScrollDecorator {}

        Column {
            id: contentColumn
            width: parent.width

            Item {
                id: topItem
                width: parent.width
                height: Math.max(topColumn.height, root.height / 3)

                Column {
                    id: topColumn
                    width: parent.width
                    anchors.centerIn: parent

                    Label {
                        id: topLabel
                        x: Theme.horizontalPageMargin
                        width: parent.width - x*2
                        height: implicitHeight + (Theme.paddingLarge*2)
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter

                        font.family: Theme.fontFamilyHeading
                        font.pixelSize: Theme.fontSizeExtraLarge
                        wrapMode: Text.WordWrap
                        color: Theme.highlightColor
                    }

                    Label {
                        id: topSmallLabel
                        x: Theme.horizontalPageMargin
                        width: parent.width - x*2
                        height: implicitHeight + Theme.paddingLarge
                        horizontalAlignment: Text.AlignHCenter

                        font.family: Theme.fontFamilyHeading
                        font.pixelSize: Theme.fontSizeSmall
                        wrapMode: Text.WordWrap
                        color: Theme.highlightColor
                    }
                }
            }

            Item {
                id: centerItem
                width: parent.width
                height: root.height / 3.5

                Column {
                    width: parent.width
                    spacing: Theme.paddingLarge
                    anchors.centerIn: parent

                    ProgressCircle {
                        id: progressCircle
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: height
                        height: Theme.itemSizeHuge
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
                        x: Theme.horizontalPageMargin
                        width: parent.width - x*2
                        visible: text.length > 0
                        horizontalAlignment: Text.AlignHCenter

                        font.pixelSize: Theme.fontSizeSmall
                        wrapMode: Text.WordWrap
                        color: Theme.highlightColor
                    }
                }
            }

            Item {
                id: bottomItem
                width: parent.width
                height: Math.max(bottomColumn.height + Theme.paddingLarge, root.height / 3)

                Column {
                    id: bottomColumn
                    width: parent.width
                    anchors.centerIn: parent
                    spacing: Theme.paddingLarge

                    Label {
                        id: bottomSmallLabel
                        x: Theme.horizontalPageMargin
                        width: parent.width - x*2
                        horizontalAlignment: Text.AlignHCenter

                        visible: text.length > 0
                        font.pixelSize: Theme.fontSizeSmall
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
                        horizontalAlignment: Text.AlignHCenter

                        visible: text.length > 0
                        font.family: Theme.fontFamilyHeading
                        font.pixelSize: Theme.fontSizeExtraLarge
                        wrapMode: Text.WordWrap
                        color: Theme.highlightColor
                    }

                    ButtonLayout {
                        Button {
                            id: button1
                            visible: text.length > 0
                            onClicked: root.button1Clicked()
                        }

                        Button {
                            id: button2
                            visible: text.length > 0
                            onClicked: root.button2Clicked()
                        }
                    }
                }
            }
        }
    }
}
