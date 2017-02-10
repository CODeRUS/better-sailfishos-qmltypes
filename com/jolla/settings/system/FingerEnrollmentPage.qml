import QtQuick 2.2
import Sailfish.Silica 1.0
import com.jolla.settings.system 1.0
import org.nemomobile.devicelock 1.0

Dialog {
    id: page
    property FingerprintSettings settings
    property variant authenticationToken
    property Component destination

    property alias instruction: instructionLabel.text
    property alias explanation: explanationLabel.text
    property string feedback

    property alias header: header
    property alias contentItem: contentItem
    default property alias _data: contentItem.data

    function goTo(target, properties) {
        var destinationProperties = {}

        for (var property in acceptDestinationProperties) {
            destinationProperties[property] = acceptDestinationProperties[property]
        }

        if (properties) for (property in properties) {
            destinationProperties[property] = properties[property]
        }

        pageStack.replace(target, destinationProperties)
    }

    acceptDestinationProperties: {
        "settings": settings,
        "authenticationToken": authenticationToken,
        "destination": destination
    }

    onRejected: {
        if (page.settings.acquiring) {
            page.settings.cancelAcquisition()
        }
    }

    DialogHeader {
        id: header
    }

    Item {
        id: contentItem

        y: header.height
        width: page.width
        height: page.height - header.height
    }

    Label {
        id: instructionLabel

        x: Theme.horizontalPageMargin
        y: header.height + Theme.paddingLarge

        width: page.width - (2 * Theme.horizontalPageMargin)
        wrapMode: Text.Wrap

        font {
            pixelSize: Theme.fontSizeExtraLarge
            family: Theme.fontFamilyHeading
        }

        color: Theme.highlightColor
    }

    Label {
        id: explanationLabel
        x: Theme.horizontalPageMargin
        y: instructionLabel.y + instructionLabel.height + Theme.paddingLarge
        width: page.width - (2 * Theme.horizontalPageMargin)
        wrapMode: Text.Wrap
        color: Theme.highlightColor
    }

    Label {
        id: feedbackLabel

        readonly property bool active: feedback.length > 0
        onActiveChanged: if (active) text = feedback

        opacity: active ? 1.0 : 0.0
        Behavior on opacity { FadeAnimation {}}

        x: Theme.horizontalPageMargin
        y: page.height - feedbackLabel.height - Theme.paddingLarge

        width: page.width - (2 * Theme.horizontalPageMargin)
        wrapMode: Text.Wrap

        font {
            pixelSize: Theme.fontSizeExtraLarge
            family: Theme.fontFamilyHeading
        }

        color: Theme.highlightColor
    }
}
