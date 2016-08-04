import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.gallery 1.0
import org.nemomobile.socialcache 1.0
import com.jolla.gallery.extensions 1.0

Page {
    id: root

    property alias socialNetwork: syncHelper.socialNetwork
    property alias dataType: syncHelper.dataType
    property alias usersModel: view.model
    property alias userDelegate: view.delegate
    property string title

    allowedOrientations: window.allowedOrientations

    onStatusChanged: {
        if (status === PageStatus.Active) {
            usersModel.refresh()
        }
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
                running: syncHelper.loading
            }
        }
        SyncHelper {
            id: syncHelper
            onLoadingChanged: {
                if (!loading) {
                    root.usersModel.refresh()
                }
            }
            onProfileDeleted: {
                if (window.pageStack.currentPage === root) {
                    var page = pageStack.currentPage
                    var prevPage = pageStack.previousPage(page)
                    while (prevPage) {
                        page = prevPage
                        prevPage = pageStack.previousPage(prevPage)
                    }
                    pageStack.pop(page)
                }
            }
        }
    }
}
