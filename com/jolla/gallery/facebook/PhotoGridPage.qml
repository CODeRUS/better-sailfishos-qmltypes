import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Gallery 1.0
import Sailfish.Accounts 1.0
import org.nemomobile.socialcache 1.0

Page {
    id: gridPage

    property string albumName
    property string albumIdentifier
    property alias model: grid.model

    // -----------------------------

    property alias currentIndex: grid.currentIndex
    allowedOrientations: window.allowedOrientations

    // The account stuff
    property string accessToken
    property int accountId: model.count > 0 ? model.getField(0, FacebookImageCacheModel.AccountId)
                                            : -1

    KeyProviderHelper {id: keyProviderHelper}

    Account {
        id: fbAccount
        function performSignIn() {
            if (status == Account.Initialized && model.clientId != "") {
                // Sign in, and get access token.
                var params = signInParameters("facebook-sync")
                params.setParameter("ClientId", keyProviderHelper.facebookClientId)
                params.setParameter("UiPolicy", SignInParameters.NoUserInteractionPolicy)
                signIn("Jolla", "Jolla", params)
            }
        }

        identifier: accountId
        onStatusChanged: performSignIn()

        onSignInResponse: {
            var accessTok = data["AccessToken"]
            if (accessTok != "") {
                gridPage.accessToken = accessTok
            }
        }
    }

    Component.onCompleted: model.requestClientId()

    Connections {
        target: model
        onClientIdChanged: fbAccount.performSignIn()
    }

    ImageGridView {
        id: grid
        anchors.fill: parent

        header: PageHeader { title: gridPage.albumName }

        delegate:  ThumbnailImage {
            source: thumbnail
            size: grid.cellSize
            onReleased: {
                pageStack.push(Qt.resolvedUrl("FullscreenPhotoPage.qml"), {
                                   accessToken: gridPage.accessToken,
                                   currentIndex: index,
                                   model: grid.model
                               })
            }
        }
    }
}
