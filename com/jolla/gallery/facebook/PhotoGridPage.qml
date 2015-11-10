import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Gallery 1.0
import Sailfish.Accounts 1.0
import com.jolla.gallery.facebook 1.0
import org.nemomobile.socialcache 1.0

Page {
    id: gridPage

    property string albumName
    property alias model: grid.model

    // -----------------------------

    property alias currentIndex: grid.currentIndex
    allowedOrientations: window.allowedOrientations

    AccessTokensProvider {id: accessTokensProvider}

    ImageGridView {
        id: grid
        anchors.fill: parent

        header: PageHeader { title: gridPage.albumName }

        delegate: ThumbnailImage {
            source: thumbnail
            size: grid.cellSize
            onReleased: {
                pageStack.push(Qt.resolvedUrl("FullscreenPhotoPage.qml"), {
                                   accessTokensProvider: accessTokensProvider,
                                   currentIndex: index,
                                   model: grid.model
                               })
            }
        }
    }

    // Requesting the accessToken for the first picture ASAP will work
    // nicely for the most common use case in which we are checking
    // the pictures from just one Facebook user.
    Component.onCompleted: if (model.count > 0) accessTokensProvider.requestAccessToken(model.getField(0, FacebookImageCacheModel.AccountId))
}
