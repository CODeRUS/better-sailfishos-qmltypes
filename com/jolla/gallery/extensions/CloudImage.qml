import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.socialcache 1.0
import Sailfish.Gallery 1.0
import Sailfish.Gallery.private 1.0
import com.jolla.gallery.extensions 1.0

MouseArea {
    id: container

    property bool isPagePortrait: fullscreenPage.isPortrait
    property bool isSplitActive: fullscreenPage.open
    property string imageId
    property bool connectedToNetwork: fullscreenPage.connectedToNetwork
    property SocialImageCache downloader: fullscreenPage.downloader
    property int accountId
    property int expires: 14 // cache time in days
    property bool caching
    property AccessTokensProvider accessTokensProvider: fullscreenPage.accessTokensProvider
    property int orientation: metadata.orientation
    readonly property bool _transpose: (orientation % 180) != 0
    property int transposedWidth: _transpose ? image.implicitHeight : image.implicitWidth
    property int transposedHeight: _transpose ? image.implicitWidth : image.implicitHeight
    property string directUrl
    property bool isCurrentItem: PathView.isCurrentItem

    property bool _downloadUrlRequested
    property bool _waitingForDownloadUrl
    property bool _noNetworkError
    property bool _failedToDownload

    signal requestDownloadUrl(string accessToken)

    opacity: Math.abs(x) <= width ? 1.0 - (Math.abs(x) / width) : 0

    onIsSplitActiveChanged: updateScale()
    onIsPagePortraitChanged: updateScale()
    onClicked: fullscreenPage.open = !fullscreenPage.open

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
        id: placeholderRect
        visible: image.status !== Image.Ready
        color: Theme.highlightColor
        opacity: 0.06
        width: container.width
        height: container.height
    }

    Label {
        id: noNetworkLabel
        anchors.centerIn: parent
        visible: _noNetworkError || _failedToDownload
                                //% "No network connection"
        text: _noNetworkError ? qsTrId("jolla_gallery_extensions-la-no_network_connection")
                                //% "Failed to download"
                              : qsTrId("jolla_gallery_extensions-la-failed_to_download")
        font.pixelSize: Theme.fontSizeLarge
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
            } else if (status === Image.Ready) {
                container.updateScale()
            }
        }
        sourceSize {
            // No point to load more than this until
            // we implement zooming
            width: Math.max(Screen.width, Screen.height)
        }
        onSourceChanged: {
            if (container.isCurrentItem) {
                fullscreenPage.currentSource = source
                fullscreenPage.currentAccountId = container.accountId
            }
        }

        Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.InOutQuad }}
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

    function updateScale() {
        if (transposedWidth == 0 || transposedHeight == 0) {
            return
        }

        if (isSplitActive) {
            var visibleWidth = delegate.isPagePortrait ? fullscreenPage.width : fullscreenPage.width * .5
            var visibleHeight = delegate.isPagePortrait ? fullscreenPage.height * .5 : fullscreenPage.height
            image.scale = Math.max(visibleWidth / transposedWidth,
                                   visibleHeight / transposedHeight)
        } else {
            var containerAspect = fullscreenPage.width / fullscreenPage.height
            var imageAspect = transposedWidth / transposedHeight

            if (imageAspect < containerAspect) {
                image.scale = fullscreenPage.height / transposedHeight
            } else {
                image.scale = fullscreenPage.width / transposedWidth
            }
        }
    }

    function download(url) {
        downloader.imageFile(url, accountId, container,
                             expires, imageId, accessToken)
    }

    BusyIndicator {
        anchors.centerIn: parent
        size: BusyIndicatorSize.Large
        running: container.caching || image.status == Image.Loading
        opacity: running ? 1 : 0
        Behavior on opacity { FadeAnimation {} }
    }
}
