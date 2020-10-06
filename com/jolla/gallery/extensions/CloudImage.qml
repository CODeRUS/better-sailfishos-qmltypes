import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.socialcache 1.0
import Sailfish.Gallery 1.0
import Sailfish.Gallery.private 1.0
import com.jolla.gallery.extensions 1.0

MouseArea {
    id: container

    property string imageId
    property bool connectedToNetwork: fullscreenPage.connectedToNetwork
    property SocialImageCache downloader: fullscreenPage.downloader
    property int accountId
    property int expires: 14 // cache time in days
    property bool caching
    property AccessTokensProvider accessTokensProvider: fullscreenPage.accessTokensProvider
    property int orientation: metadata.orientation
    readonly property bool _transpose: (orientation % 180) != 0
    property string directUrl
    property bool isCurrentItem: PathView.isCurrentItem
    property QtObject modelItem: model

    property bool _downloadUrlRequested
    property bool _waitingForDownloadUrl
    property bool _noNetworkError
    property bool _failedToDownload

    signal requestDownloadUrl(string accessToken)

    onClicked: fullscreenPage.overlay.active = !fullscreenPage.overlay.active
    onConnectedToNetworkChanged: {
        if (connectedToNetwork && _noNetworkError) {
            resolveCachedUrl()
        }
    }
    onDownloaderChanged: resolveCachedUrl()
    onAccountIdChanged: resolveCachedUrl()
    onAccessTokensProviderChanged: resolveCachedUrl()
    onIsCurrentItemChanged: {
        if (isCurrentItem) {
            fullscreenPage.currentSource = image.source
            fullscreenPage.currentAccountId = accountId
        }
    }

    ImageMetadata {
        id: metadata
        source: image.source
        autoUpdate: false
    }

    Connections {
        target: container.accessTokensProvider
        onAccessTokenRetrieved: {
            if (container.accountId == accountId && _waitingForDownloadUrl) {
                _waitingForDownloadUrl = false
                _downloadUrlRequested = true
                container.requestDownloadUrl(accessToken)
            }
        }
    }

    Rectangle {
        visible: image.status !== Image.Ready
        color: Theme.highlightColor
        opacity: 0.06
        width: container.width
        height: container.height
    }

    InfoLabel {
        anchors.verticalCenter: parent.verticalCenter
        color: Theme.highlightColor
        visible: _noNetworkError || _failedToDownload
        text: _noNetworkError ? //% "No network connection"
                                qsTrId("jolla_gallery_extensions-la-no_network_connection")
                              : //% "Failed to download"
                                qsTrId("jolla_gallery_extensions-la-failed_to_download")
    }

    Image {
        id: image
        asynchronous: true
        anchors.centerIn: parent
        rotation: -container.orientation
        onStatusChanged: {
            if (status === Image.Error) {
                if (!container._downloadUrlRequested) {
                    // Image came from cache but failed to load.
                    // Refresh access token and try again.
                    requestAccessToken()
                }
            }
        }
        sourceSize {
            // No point to load more than this until
            // we implement zooming
            width: Math.max(Screen.width, Screen.height)
        }
        width: _transpose ? parent.height : parent.width
        height: _transpose ? parent.width : parent.height
        fillMode: Image.PreserveAspectFit
        onSourceChanged: {
            if (container.isCurrentItem) {
                fullscreenPage.currentSource = source
                fullscreenPage.currentAccountId = container.accountId
            }
        }

    }

    function resolveCachedUrl() {
        if (downloader && accessTokensProvider
              && imageId != ""
              && accountId > 0) {
            _waitingForDownloadUrl = false
            _downloadUrlRequested = false
            _noNetworkError = false
            _failedToDownload = false
            caching = false
            var cached = downloader.cached(imageId)
            if (cached != "") {
                image.source = cached
                return
            }

            if (directUrl !== "") {
                // direct url was given, no need to query access token and download url
                caching = true
                download(directUrl)
            } else {
                if (!fullscreenPage.connectedToNetwork) {
                    _noNetworkError = true
                    return
                }
                requestAccessToken()
            }
        }
    }

    function requestAccessToken() {
        _waitingForDownloadUrl = true
        caching = true
        accessTokensProvider.requestAccessToken(accountId)
    }

    // SocialImageCache will call one of these two methods after the image has been
    // either dowloaded or download fails.
    function imageCached(imageFile) {
        image.source = imageFile
        caching = false
    }

    function downloadError() {
        if (!_downloadUrlRequested) {
            // Something went wrong. Try to refresh accessToken if that
            // hasn't been done yet.
            requestAccessToken()
        }
        caching = false
        _failedToDownload = true
    }


    function download(url) {
        downloader.imageFile(url, accountId, container,
                             expires, imageId, accessToken)
    }

    function downloadWithAccessToken(url, specificAccessToken) {
        downloader.imageFile(url, accountId, container,
                             expires, imageId, specificAccessToken)
    }

    BusyIndicator {
        anchors.centerIn: parent
        size: BusyIndicatorSize.Large
        running: container.caching || image.status == Image.Loading
    }
}
