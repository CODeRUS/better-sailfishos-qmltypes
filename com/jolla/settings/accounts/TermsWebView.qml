import QtQuick 2.0
import QtWebKit 3.0
import QtWebKit.experimental 1.0
import Sailfish.Silica 1.0

Page {
    id: webPage

    property string title
    property alias url: webView.url

    SilicaWebView {
        id: webView

        anchors.fill: parent
        experimental.autoCorrect: false
        experimental.temporaryCookies: true
        experimental.deviceWidth: width
        experimental.deviceHeight: height

        experimental.preferences.minimumFontSize: Theme.fontSizeTinyBase
        experimental.preferences.defaultFontSize: Theme.fontSizeTinyBase

        onNavigationRequested: {
            request.action = (request.url == webPage.url) ? WebView.AcceptRequest : WebView.IgnoreRequest
        }

        header: PageHeader {
            title: webPage.title
        }
    }
}

