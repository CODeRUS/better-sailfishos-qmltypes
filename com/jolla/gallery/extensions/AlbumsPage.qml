import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.socialcache 1.0
import Nemo.DBus 2.0
import Sailfish.Accounts 1.0
import com.jolla.gallery 1.0
import com.jolla.gallery.extensions 1.0
import Nemo.Connectivity 1.0

MediaSourcePage {
    id: root

    property alias accessTokenService: _accessTokensProvider.service
    property alias clientId: _accessTokensProvider.clientId
    property string syncService

    // provided by the UsersPage.qml
    property string userId
    property SocialImageCache fullSizeDownloader: SocialImageCache {}
    property AccessTokensProvider accessTokensProvider: AccessTokensProvider {
        id: _accessTokensProvider
    }
    property SyncHelper syncHelper: _syncHelper

    allowedOrientations: window.allowedOrientations
    property bool _isPortrait: orientation === Orientation.Portrait
                               || orientation === Orientation.PortraitInverted
    property bool _synced
    property alias connectedToNetwork: connectionHelper.online
    property KeyProviderHelper keyProviderHelper: KeyProviderHelper {}
    property alias albumDelegate: view.delegate
    property alias albumModel: view.model
    property alias socialNetwork: _syncHelper.socialNetwork

    onStatusChanged: {
        if (status === PageStatus.Active) {
            albumModel.refresh()
            if (!_synced) {
                var accountIdentifiers = accountManager.accountIdentifiers
                for (var i = 0; i < accountIdentifiers.length; ++i) {
                    var account = accountManager.account(accountIdentifiers[i])
                    if (account.isEnabledWithService(root.syncService)) {
                        var profileIds = syncManager.profileIds(account.identifier, root.syncService)
                        for (var j = 0; j < profileIds.length; j++) {
                            buteoDaemon.call("startSync", profileIds[j])
                        }
                    }
                }
                _synced = true
            }
        }
    }

    DBusInterface {
        id: buteoDaemon
        service: "com.meego.msyncd"
        path: "/synchronizer"
        iface: "com.meego.msyncd"
    }

    AccountManager {
        id: accountManager
    }

    AccountSyncManager {
        id: syncManager
    }

    ConnectionHelper {
        id: connectionHelper
    }

    SilicaListView {
        id: view
        anchors.fill: parent
        header: PageHeader {
            id: pageHeader
            title: root.title
            BusyIndicator {
                id: busyIndicator
                parent: pageHeader.extraContent
                anchors {
                    verticalCenter: parent.verticalCenter
                    right: parent.right
                    rightMargin: Theme.paddingLarge
                }
                size: BusyIndicatorSize.ExtraSmall
                running: _syncHelper.loading
            }
        }
        cacheBuffer: screen.height
        SyncHelper {
            id: _syncHelper
            dataType: SocialSync.Images
            onLoadingChanged: {
                if (!loading) {
                    root.albumModel.refresh()
                }
            }
            onProfileDeleted: {
                var page = pageStack.currentPage
                var prevPage = pageStack.previousPage(page)
                while (prevPage) {
                    page = prevPage
                    prevPage = pageStack.previousPage(prevPage)
                }
                pageStack.pop(page)
            }
        }

        VerticalScrollDecorator {}
    }
}
