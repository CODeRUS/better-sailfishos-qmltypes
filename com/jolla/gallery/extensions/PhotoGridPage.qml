import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Gallery 1.0
import Sailfish.Accounts 1.0
import com.jolla.gallery.dropbox 1.0
import org.nemomobile.socialcache 1.0

Page {
    id: gridPage

    property string albumName
    property string albumIdentifier
    property string userIdentifier
    property url placeholderThumbnail: "image://theme/icon-m-image"
    property alias model: grid.model
    property SyncHelper syncHelper

    property bool loading: syncHelper ? syncHelper.loading : false
    property alias currentIndex: grid.currentIndex
    allowedOrientations: window.allowedOrientations

    signal imageClicked()

    onLoadingChanged: {
        if (!loading) {
            model.loadImages()
        }
    }

    ImageGridView {
        id: grid
        anchors.fill: parent

        header: PageHeader {
            id: pageHeader
            title: gridPage.albumName
            BusyIndicator {
                id: busyIndicator
                parent: pageHeader.extraContent
                anchors {
                    verticalCenter: parent.verticalCenter
                    right: parent.right
                    rightMargin: Theme.paddingLarge
                }
                size: BusyIndicatorSize.ExtraSmall
                running: syncHelper.loading
            }
        }

        delegate: ThumbnailImage {
            source: thumbnail
            size: grid.cellSize
            onReleased: gridPage.imageClicked()
            Image {
                anchors.fill: parent
                visible: thumbnail.length === 0
                source: placeholderThumbnail
            }
        }
    }
}
