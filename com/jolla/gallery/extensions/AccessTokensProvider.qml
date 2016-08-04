import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Gallery 1.0
import Sailfish.Accounts 1.0

Item {
    id: root

    property var _accounts: ({})
    property string service
    property string clientId

    signal accessTokenRetrieved(int accountId, string accessToken)

    function requestAccessToken(accountId) {
        if (!_accounts.hasOwnProperty(accountId)) {
            if (!expiryTimer.running) {
                expiryTimer.start()
            }

            _accounts[accountId] = accountComponent.createObject(root, {"identifier": accountId})
            return
        }

        if (_accounts[accountId].accessToken !== "") {
            accessTokenRetrieved(accountId, _accounts[accountId].accessToken)
        }
    }

    property Component accountComponent: Component {
        Account {
            property string accessToken

            onAccessTokenChanged: {
                root.accessTokenRetrieved(identifier, accessToken)
            }

            onStatusChanged: {
                if (status == Account.Initialized) {
                    // Sign in, and get access token.
                    var params = signInParameters(root.service)
                    params.setParameter("ClientId", root.clientId)
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

    Timer {
        id: expiryTimer
        interval: 5*60*1000
        onTriggered: {
            // assume that locally cached accessTokens are good for 5 minutes,
            // after that request again from signond
            // FIXME: we shouldn't cache locally at all, it is possible that the
            // access token in signond expires and while this timer is running
            // and locally cached version will be invalid during that time
            root._accounts = {}
        }
    }
}
