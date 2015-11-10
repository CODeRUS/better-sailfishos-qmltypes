import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Contacts 1.0

import "contactcardmodelfactory.js" as ModelFactory
import "numberutils.js" as NumberUtils

ExpandingDelegate {
    id: detailItem

    property string detailType
    property variant detailData
    property bool hidePhoneActions
    property bool disablePhoneActions

    property bool _disableActionButtons

    // Signals to tell that some contact card action item has been clicked.
    // Yep, it's a string because the phone number can start with the '+' char.
    signal callClicked(string number, string connection)
    signal smsClicked(string number, string connection)
    signal emailClicked(string email)
    signal imClicked(string localUid, string remoteUid)
    signal addressClicked(string address, variant addressParts)
    signal websiteClicked(string url)
    signal dateClicked(variant date)

    function handleActionClicked(actionType) {
        var actionValue = detailValue

        // Sanitize phone numbers before submitting them further.
        switch(actionType) {
        case "sms":
            actionValue = NumberUtils.sanitizePhoneNumber(actionValue)
            break;
        }

        switch(actionType) {
        case "call":
            callClicked(actionValue, "gsm")
            break;
        case "sms":
            smsClicked(actionValue, "gsm")
            break;
        case "email":
            emailClicked(actionValue)
            break;
        case "im":
            imClicked(detailData.localUid, detailData.remoteUid)
            break;
        case "address":
            addressClicked(actionValue, detailData)
            break;
        case "website":
            websiteClicked(actionValue)
            break;
        case "date":
            dateClicked(detailData.date)
            break;
        }
    }

    onActiveChanged: {
        if (actionDetailsModel.count == 0) {
            if (hidePhoneActions && detailType === "phone") {
                return
            } else {
                ModelFactory.getDetailsActionItemsModel(actionDetailsModel, detailType)
            }
        }
    }

    // In case modem/SIM is ready later
    onHidePhoneActionsChanged: {
        if (!hidePhoneActions && detailType === "phone" && actionDetailsModel.count == 0) {
            ModelFactory.getDetailsActionItemsModel(actionDetailsModel, detailType)
        }
    }
    onDisablePhoneActionsChanged: {
        if (detailType === "phone") {
            _disableActionButtons = disablePhoneActions
        }
    }

    expandingContent: [
        Grid {
            id: grid
            columns: 2
            spacing: actionDetailsModel.count > 1 ? Theme.paddingLarge : 0

            Repeater {
                model: actionDetailsModel
                Button { text: actionLabel; enabled: !_disableActionButtons; onClicked: handleActionClicked(actionType) }
            }
        }
    ]

    ListModel { id: actionDetailsModel }
}
