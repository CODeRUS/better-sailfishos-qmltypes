import QtQuick 2.0
import Sailfish.Silica 1.0

SilicaControl {
    id: root

    property bool open
    property bool _open
    property int horizontalMargin: Theme.horizontalPageMargin
    property int bottomMargin
    property int collapsedHeight
    property int expandedHeight
    property bool expandOnClick: true
    readonly property bool expandable: expandedHeight > collapsedHeight
    default property alias children: content.data

    signal clicked

    width: parent ? parent.width : Screen.width
    height: _open ? expandedHeight : collapsedHeight

    highlighted: content.pressed && content.containsMouse

    onClicked: if (expandOnClick) open = !open
    onOpenChanged: {
        heightBehavior.enabled = true
        _open = open
        heightBehavior.enabled = false
    }

    Behavior on height {
        id: heightBehavior
        enabled: false
        NumberAnimation {
            id: animation
            target: root
            property: "height"
            duration: expandedHeight > Screen.height ? 400 : 200
            easing.type: Easing.InOutQuad
        }
    }

    MouseArea {
        id: content
        anchors {
            fill: parent
            bottomMargin: root.bottomMargin
        }
        enabled: expandable
        onClicked: parent.clicked()
    }

    Icon {
        id: icon
        opacity: expandable ? 1.0 : 0.0
        Behavior on opacity { FadeAnimator {}}
        anchors {
            right: parent.right
            bottom: parent.bottom
            rightMargin: horizontalMargin
            bottomMargin: Theme.paddingSmall
        }
        source: "image://theme/icon-lock-more"
    }

    OpacityRampEffect {
        property real ratio: expandable ? (expandedHeight - height) / (expandedHeight - collapsedHeight)
                                        : 1.0
        slope: 2 * Math.min(1.0, ratio)
        offset: 0.5
        sourceItem: content
        enabled: expandable && !(open && !animation.running)
        direction: OpacityRamp.TopToBottom
    }
}
