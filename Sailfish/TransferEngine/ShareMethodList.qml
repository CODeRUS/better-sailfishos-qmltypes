import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.TransferEngine 1.0
import com.jolla.settings.accounts 1.0
import com.jolla.signonuiservice 1.0

SilicaListView {
    id: rootList

    property url source
    property variant content: ({})

    property alias filter: transferMethodsModel.filter

    property alias containerPage: accountCreator.endDestination
    property alias serviceFilter: accountCreator.serviceFilter
    property bool showAddAccount: true
    property var shareEndDestination

    // allows to show extra items for sharing possibilities
    property Component additionalShareComponent

    model: SailfishTransferMethodsModel { id: transferMethodsModel }

    width: parent.width
    height: Theme.itemSizeSmall * transferMethodsModel.count

    delegate: ShareMethodItem {
        width: rootList.width
        iconSource: model.accountIcon
        // Plugins may provide translation id and the translation for the display name
        // This module already loads plugin translations so let's make sure that also
        // display name is translated if it contains the id..
        text: qsTrId(displayName)
        description: userName

        onClicked: {
            pageStack.animatorPush(shareUIPath, {
                                       source: rootList.source,
                                       content: rootList.content,
                                       methodId: methodId,
                                       displayName: displayName,
                                       accountId: accountId,
                                       accountName: userName,
                                       shareEndDestination: rootList.shareEndDestination
                                   })
        }
    }

    footer: Column {
        width: rootList.width

        Loader {
            sourceComponent: rootList.additionalShareComponent
            width: parent.width
        }

        ShareMethodItem {
            id: addItem

            visible: rootList.showAddAccount && transferMethodsModel.ready
            iconSource: "image://theme/icon-m-add" + (addItem.highlighted ? "?" + Theme.highlightColor : "")
            //% "Add account"
            text: qsTrId("transferui-la-add_account")
            onClicked: {
                jolla_signon_ui_service.inProcessParent = containerPage
                accountCreator.startAccountCreation()
            }
        }
    }

    ViewPlaceholder {
        enabled: !rootList.showAddAccount && !rootList.additionalShareComponent
                 && transferMethodsModel.count === 0 && transferMethodsModel.ready

        //: Empty state placeholder for share page
        //% "No sharing accounts available. You can add accounts in settings"
        text: qsTrId("transferui-la-no_accounts")
    }

    SignonUiService {
        id: jolla_signon_ui_service
    }

    AccountCreationManager {
        id: accountCreator
    }
}
