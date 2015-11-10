import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: root
    property int timerInterval: 10000
    property variant model

    width: Theme.itemSizeExtraLarge
    height: width

    ListView {
        id: slideShow
        interactive: false
        currentIndex: 0
        clip: true
        orientation: ListView.Horizontal
        anchors.fill: parent
        model: root.model

        delegate: Image {
            source: model.thumbnail != "" ? model.thumbnail
                                          : "image://theme/graphic-service-facebook"
            fillMode: Image.PreserveAspectCrop
            clip: true
            asynchronous: true
            width: slideShow.width
            height: slideShow.height
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
