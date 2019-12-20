import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: root

    // Between 7 and 14 s, it is funnier when it is random
    property int timerInterval: 7000 +  Math.floor((Math.random() * 7000));
    property variant model
    property string serviceIcon
    property bool highlighted

    width: Theme.itemSizeExtraLarge
    height: width

    ListView {
        id: slideShow
        interactive: false
        currentIndex: 0
        clip: true

        opacity: highlighted ? 0.5 : 1
        orientation: ListView.Horizontal
        anchors.fill: parent
        model: root.model

        delegate: Image {
            source: model.thumbnail != "" ? model.thumbnail
                                          : root.serviceIcon
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            width: slideShow.width
            height: slideShow.height
        }
    }
    Rectangle {
        anchors.fill: parent
        visible: slideShow.count == 0
        gradient: Gradient {
            GradientStop { position: 0.0; color: Theme.rgba(Theme.primaryColor, 0.1) }
            GradientStop { position: 1.0; color: Theme.rgba(Theme.primaryColor, 0.05) }
        }
        Image {
            source: slideShow.count == 0 ? "image://theme/icon-m-image" + (highlighted ? "?" + Theme.highlightColor : "")
                                         : ""
            anchors.centerIn: parent
        }
    }

    Timer {
        property int modelCount: root.model ? root.model.count : 0
        interval: root.timerInterval
        repeat: true
        running: modelCount > 1 && window.applicationActive && root.visible
        onTriggered: slideShow.currentIndex = (slideShow.currentIndex + 1) % model.count
    }

}
