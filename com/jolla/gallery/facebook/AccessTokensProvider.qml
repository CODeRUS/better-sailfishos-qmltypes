import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Gallery 1.0
import Sailfish.Accounts 1.0
import org.nemomobile.socialcache 1.0

QtObject {
    id: root

    property var _accounts: { return {} }

    signal accessTokenRetrieved(string accountId, string accessToken)

    function requestAccessToken(accountId) {
        if (!_accounts.hasOwnProperty(accountId)) {
            _accounts[accountId] = accountComponent.createObject(root, {"identifier": accountId})
            return
        }

        if (_accounts[accountId].accessToken !== "") {
            accessTokenRetrieved(accountId, _accounts[accountId].accessToken)
        }
    }

    property KeyProviderHelper keyProviderHelper: KeyProviderHelper {}

    property Component accountComponent: Component {

        Account {
            property string accessToken

            onAccessTokenChanged: {
                root.accessTokenRetrieved(identifier, accessToken)
            }

            onStatusChanged: {
                if (status == Account.Initialized) {
                    // Sign in, and get access token.
                    var params = signInParameters("facebook-sync")
                    params.setParameter("ClientId", root.keyProviderHelper.facebookClientId)
                    params.setParameter("UiPolicy", SignInParameters.NoUserInteractionPolicy)
                    signIn("Jolla", "Jolla", params)
                }
            }

            onSignInResponse: {
                var accessTok = data["AccessToken"]
                if (accessTok != "") {
                    accessToken = accessTok
                }
            }
        }
    }
}
