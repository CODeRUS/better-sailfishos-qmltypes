import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.gallery 1.0
import org.nemomobile.socialcache 1.0
import com.jolla.gallery.extensions 1.0

GalleryIcon {
     socialNetwork: SocialSync.Dropbox
     dataType: SocialSync.Images
     serviceIcon: "image://theme/graphic-service-dropbox"
}
