import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page

    property alias source: shareMethodList.source
    property alias mimeType: shareMethodList.filter
    property alias content: shareMethodList.content
    property alias additionalShareComponent: shareMethodList.additionalShareComponent
    property alias serviceFilter: shareMethodList.serviceFilter
    property alias showAddAccount: shareMethodList.showAddAccount

    //: Page header for share method selection
    //% "Share"
    property string header: qsTrId("transferui-he-share")

    property var shareEndDestination
    property var _implicitShareEndDestination

    onStatusChanged: {
        // can get previous page only when in pagestack
        if (status == PageStatus.Active) {
            _implicitShareEndDestination = pageStack.previousPage(page)
        }
    }

    ShareMethodList {
        id: shareMethodList

        opacity: model.ready ? 1.0 : 0.0
        Behavior on opacity { FadeAnimator {}}
        height: parent.height
        header: PageHeader {
            title: page.header
        }
        containerPage: page
        shareEndDestination: page.shareEndDestination ? page.shareEndDestination : page._implicitShareEndDestination
    }
}
