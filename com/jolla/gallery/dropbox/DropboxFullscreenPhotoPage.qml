import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.socialcache 1.0
import com.jolla.gallery.extensions 1.0
import com.jolla.gallery.dropbox 1.0

FullscreenPhotoPage {
    id: fullscreenPage

    delegate: CloudImage {
        imageId: model.id
        accountId: model.accountId
        width: slideshowView.width
        height: slideshowView.height

        onRequestDownloadUrl: {
            download(fullscreenPage.model.getField(index, DropboxImageCacheModel.Image))
        }
    }

    onDeletePhoto: {
        var imageUrl = model.getField(index, DropboxImageCacheModel.Image)
        var imagePath = DropboxImageUrlHelper.pathFromImageUrl(imageUrl)
        if (imagePath.length === 0) {
            console.warn("Failed to determine remote path of image from url: " + imageUrl)
            return
        }

        var doc = new XMLHttpRequest()
        doc.onreadystatechange = function() {
            if (doc.readyState === XMLHttpRequest.DONE) {
                if (doc.status === 200) {
                    model.removeImage(imageUrl)
                } else {
                    console.warn("Failed to delete Dropbox image: " + doc.responseText)
                }
            }
        }
        var url = "https://api.dropboxapi.com/2/files/delete_v2"
        doc.open("POST", url, true)
        doc.setRequestHeader("Authorization", "Bearer " + accessToken)
        doc.setRequestHeader("Content-Type", "application/json")
        doc.send(JSON.stringify({ "path": imagePath }))
    }
}
