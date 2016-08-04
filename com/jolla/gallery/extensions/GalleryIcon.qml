import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.gallery 1.0
import org.nemomobile.socialcache 1.0

MediaSourceIcon {
    id: root

    property int modelCount: model ? model.count : 0
    property alias socialNetwork: syncHelper.socialNetwork
    property alias dataType: syncHelper.dataType
    property string serviceIcon

    timerEnabled: modelCount > 0

    SyncHelper {
        id: syncHelper
    }

    Item {
        anchors.fill: parent
        opacity: syncHelper.loading ? 0.3 : 1

        ListView {
            id: slideShow
            visible: timerEnabled
            interactive: false
            currentIndex: 0
            clip: true
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

        Image {
            id: dropboxIcon
            anchors.fill: parent
            Behavior on opacity { NumberAnimation { duration: 5000 }}
            source: root.serviceIcon
            fillMode: Image.PreserveAspectCrop
            clip: true
            opacity: timerEnabled ? 0 : 1
        }
    }

    BusyIndicator {
        visible: syncHelper.loading
        size: BusyIndicatorSize.Medium
        running: visible
        anchors.centerIn: parent
    }

    onTimerTriggered: slideShow.currentIndex = (slideShow.currentIndex + 1) % model.count
}
