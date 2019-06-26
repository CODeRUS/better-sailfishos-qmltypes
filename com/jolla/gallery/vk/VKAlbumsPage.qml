import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.socialcache 1.0
import com.jolla.gallery.extensions 1.0

AlbumsPage {
    id: root

    property int accountId

    accessTokenService: "vk-sync"
    clientId: keyProviderHelper.vkClientId
    syncService: "vk-images"
    socialNetwork: SocialSync.VK
    albumDelegate: AlbumDelegate {
        id: albumDelegate
        albumName: model.text
        albumIdentifier: model.albumId
        userIdentifier: model.userId
        property int accountIdentifier: model.accountId
        serviceIcon: "image://theme/graphic-service-vk"
        imagesModel: VKImageCacheModel {
            function nodeIdentifierValue() {
                return imagesModel.constructNodeIdentifier(albumDelegate.accountIdentifier, albumDelegate.userIdentifier, albumDelegate.albumIdentifier, "")
            }

            Component.onCompleted: refresh()
            type: VKImageCacheModel.Images
            nodeIdentifier: nodeIdentifierValue()
            downloader: VKImageDownloader
        }

        Component {
            id: photoGridComponent
            PhotoGridPage {
                onImageClicked: {
                    pageStack.push(Qt.resolvedUrl("VKFullscreenPhotoPage.qml"), {
                                                  "currentIndex": currentIndex,
                                                  "model": model,
                                                  "downloader": Qt.binding(function() { return root.fullSizeDownloader }),
                                                  "connectedToNetwork": Qt.binding(function() { return root.connectedToNetwork }),
                                                  "accessTokensProvider": Qt.binding(function() { return root.accessTokensProvider })
                                                })
                }
            }
        }

        onClicked: {
            imagesModel.loadImages()
            window.pageStack.animatorPush(photoGridComponent,
                                          {   "albumName": albumName,
                                              "albumIdentifier": albumIdentifier,
                                              "userIdentifier": userIdentifier,
                                              "model": imagesModel,
                                              "fullSizeDownloader": Qt.binding(function() { return root.fullSizeDownloader }),
                                              "syncHelper": Qt.binding(function() { return root.syncHelper }),
                                              "accessTokensProvider": Qt.binding(function() { return root.accessTokensProvider }) })
        }
    }

    albumModel: VKImageCacheModel {
        id: vkAlbums
        type: VKImageCacheModel.Albums
        nodeIdentifier: vkAlbums.constructNodeIdentifier(root.accountId, root.userId, "", "")
        Component.onCompleted: refresh()
        onNodeIdentifierChanged: refresh()
        downloader: VKImageDownloader
    }
}
