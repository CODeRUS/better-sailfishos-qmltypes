import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.socialcache 1.0
import com.jolla.gallery.extensions 1.0

FullscreenPhotoPage {
    id: fullscreenPage

    header: FullscreenPhotoHeader {
        photoName: fullscreenPage.model.getField(fullscreenPage.currentIndex,
                                                    DropboxImageCacheModel.Title)
        dateTime: fullscreenPage.model.getField(fullscreenPage.currentIndex,
                                                DropboxImageCacheModel.DateTaken)
    }

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
        var imageUrl = fullscreenPage.model.getField(index, DropboxImageCacheModel.Image)

        var doc = new XMLHttpRequest()
        doc.onreadystatechange = function() {
            if (doc.readyState === XMLHttpRequest.DONE) {
                if (doc.status === 200) {
                    var doPop = imageUrl === model.getField(currentIndex, DropboxImageCacheModel.Image)
                    model.removeImage(imageUrl)
                    if (doPop) {
                        // pop() if user havent swiped to different pic while remorse timer was running
                        pageStack.pop()
                    }
                } else {
                    console.warn("Failed to delete Dropbox image")
                }
            }
        }
        var url = "https://api.dropboxapi.com/1/fileops/delete?root=auto&path=" + encodeURIComponent(
                    imageUrl.replace(/https:\/\/content.dropboxapi.com\/1\/files\/auto\//gi,''))
        doc.open("GET", url)
        doc.setRequestHeader("Authorization", "Bearer "+ accessToken);
        doc.send()
    }
}
