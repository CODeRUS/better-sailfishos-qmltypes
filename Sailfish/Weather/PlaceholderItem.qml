import QtQuick 2.2
import Sailfish.Silica 1.0

Item {
    id: root

    property bool error
    property bool empty
    property bool enabled
    property Flickable flickable
    property Item _animationHint
    property alias text: mainLabel.text

    signal reload

    function update() {
        if (!_animationHint && enabled && flickable) {
            _animationHint = animationHint.createObject(root)
        }
    }
    Component.onCompleted: update()
    onEnabledChanged: update()
    onFlickableChanged: update()

    width: parent.width
    height: mainLabel.height + Theme.paddingLarge + (error ? button.height : busyIndicator.height)
    opacity: enabled ? 1.0 : 0.0
    Behavior on opacity { OpacityAnimator { easing.type: Easing.InOutQuad;  duration: 400 } }
    Label {
        id: mainLabel

        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignHCenter
        //% "Loading failed"
        text: error ? qsTrId("weather-la-loading_failed")
                    //% "Loading"
                    : qsTrId("weather-la-loading")
        font {
            pixelSize: Theme.fontSizeExtraLarge
            family: Theme.fontFamilyHeading
        }
        anchors {
            left: parent.left
            right: parent.right
            margins: Theme.paddingLarge
        }
        color: Theme.highlightColor
        opacity: 0.6
    }
    BusyIndicator {
        id: busyIndicator
        running: parent.opacity > 0 && !error && !empty
        size: BusyIndicatorSize.Large
        anchors {
            top: mainLabel.bottom
            topMargin: Theme.paddingLarge
            horizontalCenter: parent.horizontalCenter
        }
    }
    Button {
        id: button
        //% "Try again"
        text: qsTrId("weather-la-try_again")
        opacity: enabled ? 1.0 : 0.0
        enabled: error
        Behavior on opacity { FadeAnimation {} }
        anchors {
            top: mainLabel.bottom
            topMargin: Theme.paddingLarge
            horizontalCenter: parent.horizontalCenter
        }
        onClicked: reload()
    }
    Component {
        id: animationHint
        PulleyAnimationHint {
            enabled: !error
            flickable: root.flickable
            width: parent.width
            height: width
            anchors.centerIn: parent
        }
    }
}
