import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.socialcache 1.0
import com.jolla.gallery.extensions 1.0

AlbumsPage {
    id: root

    accessTokenService: "onedrive-sync"
    clientId: keyProviderHelper.oneDriveClientId
    syncService: "onedrive-images"
    socialNetwork: SocialSync.OneDrive
    albumDelegate: AlbumDelegate {
        id: albumDelegate
        albumName: model.title
        albumIdentifier: model.id
        userIdentifier: model.userId
        serviceIcon: "image://theme/graphic-service-onedrive"
        imagesModel: OneDriveImageCacheModel {
            function nodeIdentifierValue() {
                if (albumDelegate.albumIdentifier == "" && albumDelegate.userIdentifier == "") {
                    return ""
                } else if (albumDelegate.albumIdentifier == "" && albumDelegate.userIdentifier != "") {
                    return "user-" + albumDelegate.userIdentifier
                } else {
                    return "album-" + albumDelegate.albumIdentifier
                }
            }

            Component.onCompleted: refresh()
            type: OneDriveImageCacheModel.Images
            nodeIdentifier: nodeIdentifierValue()
            downloader: OneDriveImageDownloader
        }

        Component {
            id: photoGridComponent
            PhotoGridPage {
                onImageClicked: {
                    pageStack.push(Qt.resolvedUrl("OneDriveFullscreenPhotoPage.qml"), {
                                                  "currentIndex": currentIndex,
                                                  "model": model,
                                                  "downloader": root.fullSizeDownloader,
                                                  "connectedToNetwork": Qt.binding(function() { return root.connectedToNetwork }),
                                                  "accessTokensProvider": root.accessTokensProvider
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
                                              "syncHelper": root.syncHelper })
        }
    }

    albumModel: OneDriveImageCacheModel {
        type: OneDriveImageCacheModel.Albums
        nodeIdentifier: root.userId
        Component.onCompleted: refresh()
        onNodeIdentifierChanged: refresh()
        downloader: OneDriveImageDownloader
    }
}
