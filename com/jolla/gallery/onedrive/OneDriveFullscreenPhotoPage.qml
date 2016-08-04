import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.socialcache 1.0
import com.jolla.gallery.extensions 1.0

FullscreenPhotoPage {
    id: fullscreenPage

    header: FullscreenPhotoHeader {
        photoName: fullscreenPage.model.getField(fullscreenPage.currentIndex,
                                                    OneDriveImageCacheModel.Title)
        dateTime: fullscreenPage.model.getField(fullscreenPage.currentIndex,
                                                OneDriveImageCacheModel.DateTaken)
    }

    delegate: CloudImage {
        id: delegateItem
        imageId: model.id
        accountId: model.accountId
        width: slideshowView.width
        height: slideshowView.height

        onRequestDownloadUrl: {
            var doc = new XMLHttpRequest()
            doc.onreadystatechange = function() {
                if (doc.readyState === XMLHttpRequest.DONE) {
                    if (doc.status === 200) {
                        var serverImage = JSON.parse(doc.responseText)
                        delegateItem.download(serverImage.location)
                    } else {
                        delegateItem.downloadError()
                    }
                }
            }

            var url = "https://apis.live.net/v5.0/" + delegateItem.imageId + "/content?suppress_redirects=true&access_token=" + accessToken
            doc.open("GET", url)
            doc.send()
        }
    }

    onDeletePhoto: {
        var imageId = fullscreenPage.model.getField(index, OneDriveImageCacheModel.OneDriveId)

        var doc = new XMLHttpRequest()
        doc.onreadystatechange = function() {
            if (doc.readyState === XMLHttpRequest.DONE) {
                if (doc.status == 200 || doc.status == 204) {
                    var doPop = imageId === fullscreenPage.model.getField(currentIndex, OneDriveImageCacheModel.OneDriveId)
                    model.removeImage(imageId)
                    if (doPop) {
                        pageStack.pop()
                    }
                } else {
                    console.warn("Failed to delete OneDrive image")
                }
            }
        }

        var url = "https://apis.live.net/v5.0/"+ imageId + "?access_token=" + accessToken
        doc.open("DELETE", url)
        doc.send()
    }
}
