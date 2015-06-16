import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.TransferEngine 1.0

Item {
    id: shareMenu

    //----------------- api:

    /*
        Example:

            var content = {
                "data": "BEGIN:VCARD;FN:John Smith;END:VCARD",
                "name": "example.vcf",
                "type": "text/vcard",
                "icon": "icon-m-people"
            }
            shareMenu.show(content, "text/vcard", page.height/3, page)
    */

    property bool active: height > 0

    function show(content, filter, maxHeight, page) {
        _page = page
        flick.opacity = 1.0
        shareList.content = content
        shareList.filter = filter
        shareMenu.height = Math.min(shareList.height + Theme.paddingLarge, maxHeight)
    }

    function close() {
        flick.opacity = 0.0
        shareMenu.height = 0
    }

    //------------------ impl:

    visible: active
    width: parent.width
    height: 0
    Behavior on height { NumberAnimation { duration: 200 } }

    property Page _page
    property int _pageStatus: _page ? _page.status : 0
    on_PageStatusChanged: {
        if (_page && _pageStatus == PageStatus.Inactive && shareMenu.active) {
            shareMenu.close()
        }
    }

    SilicaFlickable {
        id: flick

        opacity: 0.0
        Behavior on opacity { FadeAnimation { } }

        clip: true
        width: parent.width
        height: parent.height - Theme.paddingLarge
        contentWidth: parent.width
        contentHeight: shareList.height > shareLabel.height ? shareList.height : shareLabel.height

        VerticalScrollDecorator {}

        Label {
            id: shareLabel
            anchors {
                rightMargin: Theme.horizontalPageMargin
                right: parent.right
            }
            //: Share menu label
            //% "Share"
            text: qsTrId("transferui-la_sharemenu_share")
            color: Theme.highlightColor
        }

        Column {
            id: col
            width: parent.width
            spacing: Theme.paddingLarge

            ShareMethodList {
                id: shareList
                width: parent.width
            }
        }
    }

    InverseMouseArea {
        anchors.fill: parent
        onClickedOutside: close()
    }
}

