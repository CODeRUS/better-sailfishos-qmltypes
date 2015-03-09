import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Contacts 1.0

import "contactcardmodelfactory.js" as ModelFactory
import "numberutils.js" as NumberUtils

Column {
    id: detailItem
    property string detailType
    property alias detailValue: contactDetailValue.text
    property alias detailTypeValue: contactDetailType.text
    property variant detailData
    property real activationProgress

    property alias active: contactDetailActions.active
    property bool _wasActive
    onActivationProgressChanged: {
        if (activationProgress == 1) {
            _wasActive = false
        }
    }

    // Signal that tells that the header needs to be opened/closed.
    signal contactDetailClicked(variant detailItem)

    // Signals to tell that some contact card action item has been clicked.
    // Yep, it's a string because the phone number can start with the '+' char.
    signal callClicked(string number, string connection)
    signal smsClicked(string number, string connection)
    signal emailClicked(string email)
    signal imClicked(string localUid, string remoteUid)
    signal addressClicked(string address, variant addressParts)
    signal websiteClicked(string url)
    signal dateClicked(variant date)

    width: parent.width

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
        _wasActive = !active
        if (actionDetailsModel.count == 0) {
            ModelFactory.getDetailsActionItemsModel(actionDetailsModel, detailType)
        }
    }

    MouseArea {
        width: parent.width
        height: childrenRect.height

        onClicked: contactDetailClicked(detailItem)

        Item {
            id: labelWrapper

            property bool active: contactDetailActions.active || (pressed && containsMouse)

            width: parent.width
            height: childrenRect.height

            // Opacity must be controlled here, as truncation/fade will override it inside the label
            opacity: active ? 1.0 : 0.5

            Label {
                id: contactDetailType
                color: parent.active ? Theme.highlightColor : Theme.primaryColor
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 2*Theme.paddingLarge
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                font {
                    family: Theme.fontFamilyHeading
                    pixelSize: Theme.fontSizeLarge
                }
            }

            Label {
                id: contactDetailValue
                color: parent.active ? Theme.highlightColor : Theme.primaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                y: contactDetailType.y + contactDetailType.height - 6  // TODO: Stupid font marginals.
                width: parent.width - 2*Theme.paddingSmall
                x: Theme.paddingSmall
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
            }
        }

        Column {
            id: contactDetailActions
            property bool active
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: labelWrapper.bottom
            }

            property real animationProgress: active ? activationProgress : (_wasActive ? (1 - activationProgress) : 0)

            height: grid.height * animationProgress
            opacity: 1 * animationProgress

            Grid {
                id: grid
                columns: 2
                spacing: actionDetailsModel.count > 1 ? Theme.paddingLarge : 0

                Repeater {
                    model: actionDetailsModel
                    Button { text: actionLabel; onClicked: handleActionClicked(actionType) }
                }
            }
        }
    }

    ListModel { id: actionDetailsModel }
}
