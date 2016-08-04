import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.socialcache 1.0
import com.jolla.gallery.extensions 1.0

FullscreenPhotoPage {
    id: fullscreenPage

    header: FullscreenPhotoHeader {
        photoName: fullscreenPage.model.getField(fullscreenPage.currentIndex,
                                                    VKImageCacheModel.Text)
        dateTime: fullscreenPage.model.getField(fullscreenPage.currentIndex,
                                                VKImageCacheModel.Date)
    }

    delegate: CloudImage {
        imageId: model.photoId
        accountId: model.accountId
        width: slideshowView.width
        height: slideshowView.height
        directUrl: model.imageSource
    }

    onDeletePhoto: {
        var imageId = fullscreenPage.model.getField(index, VKImageCacheModel.PhotoId)

        var doc = new XMLHttpRequest()
        doc.onreadystatechange = function() {
            if (doc.readyState === XMLHttpRequest.DONE) {
                if (doc.status == 200) {
                    var doPop = imageId === fullscreenPage.model.getField(currentIndex, VKImageCacheModel.PhotoId)
                    model.removeImage(imageId)
                    if (doPop) {
                        pageStack.pop()
                    }
                } else {
                    console.warn("Failed to delete VK image")
                }
            }
        }

        var url = "https://api.vk.com/method/photos.delete?photo_id="+ imageId + "&access_token=" + accessToken
        doc.open("POST", url)
        doc.send()
    }
}
