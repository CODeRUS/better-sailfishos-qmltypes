import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.socialcache 1.0

Page {
    id: root
    property string userId // provided by the UsersPage.qml
    property string title

    allowedOrientations: window.allowedOrientations
    property bool _isPortrait: orientation === Orientation.Portrait
                               || orientation === Orientation.PortraitInverted

    SilicaListView {
        anchors.fill: parent
        header: PageHeader { title: root.title }
        cacheBuffer: screen.height
        delegate: AlbumDelegate {
            albumName: model.title
            albumIdentifier: model.facebookId
            userIdentifier: model.userId

            onClicked: {
                imagesModel.loadImages()
                window.pageStack.animatorPush(Qt.resolvedUrl("PhotoGridPage.qml"),
                                              {"albumName": albumName,
                                                  "albumIdentifier": albumIdentifier,
                                                  "model": imagesModel})
            }
        }

        model: FacebookImageCacheModel {
            id: fbAlbums
            type: FacebookImageCacheModel.Albums
            nodeIdentifier: root.userId
            Component.onCompleted: refresh()
            onNodeIdentifierChanged: refresh()
            downloader: FacebookImageDownloader
        }

        SyncHelper {
            socialNetwork: SocialSync.Facebook
            dataType: SocialSync.Images
            onLoadingChanged: {
                if (!loading) {
                    fbAlbums.refresh()
                }
            }
            onProfileDeleted: {
                var page = pageStack.currentPage
                var prevPage = pageStack.previousPage(page)
                while (prevPage) {
                    page = prevPage
                    prevPage = pageStack.previousPage(prevPage)
                }
                pageStack.pop(page)
            }
        }

        VerticalScrollDecorator {}
    }
}
