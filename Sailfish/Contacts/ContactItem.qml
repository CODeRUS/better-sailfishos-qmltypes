/*
* Copyright (c) 2013 - 2020 Jolla Pty Ltd.
* Copyright (c) 2020 Open Mobile Platform LLC.
*
* License: Proprietary
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.contacts 1.0

ListItem {
    id: root

    property alias firstText: row.firstText
    property alias secondText: row.secondText
    property string matchText
    property alias unnamed: row.unnamed
    property int presenceState
    property alias iconSource: icon.source

    property string searchString

    property real leftMargin: Theme.horizontalPageMargin
    property real leftMarginOffset

    // Same as: SearchField.textLeftMargin
    property real searchLeftMargin: Theme.itemSizeSmall + Theme.paddingMedium

    property bool _matchTextVisible: searchString.length > 0 && matchText.length > 0 && firstText != matchText
    contentHeight: _matchTextVisible ? Theme.itemSizeMedium : Theme.itemSizeSmall

    function _regExpFor(term) {
        // Escape any significant chars in the search term
        term = term.replace(/([.?*+^$[\]\\(){}|-])/g, "\\$1")
        return new RegExp(term, 'i')
    }

    ContactNameRow {
        id: row

        anchors {
            left: parent.left
            right: icon.left
            leftMargin: root.leftMargin + root.leftMarginOffset
            rightMargin: icon.width ? spacing : 0
            verticalCenter: parent.verticalCenter
            verticalCenterOffset: _matchTextVisible ? -matchDataText.height/2 : 0
        }
    }

    Label {
        id: matchDataText

        anchors {
            left: row.left
            right: row.right
            top: row.bottom
        }

        text: matchText
        color: highlighted ? Theme.secondaryHighlightColor: Theme.secondaryColor
        truncationMode: TruncationMode.Fade
        textFormat: Text.AutoText
        visible: _matchTextVisible
    }

    Image {
        id: icon

        anchors {
            right: parent.right
            rightMargin: Theme.horizontalPageMargin
            verticalCenter: parent.verticalCenter
        }

        // use app icons, scaled to half their size
        width: visible ? Theme.itemSizeMedium / 2 : 0
        height: Theme.itemSizeMedium / 2
        source: iconSource
        visible: iconSource != ''
    }
    ContactPresenceIndicator {
        id: presence
        visible: !offline
        anchors {
            top: row.top
            topMargin: row.firstNameLabel.baselineOffset + Theme.paddingMedium
            left: row.left
            right: undefined
        }
        animationEnabled: false
        presenceState: root.presenceState
    }

    states: State {
        when: searchString !== ''
        PropertyChanges {
            target: root
            leftMargin: root.searchLeftMargin
        }
        PropertyChanges {
            target: row.firstNameLabel
            text: Theme.highlightText(firstText, _regExpFor(searchString), Theme.highlightColor)
            textFormat: Text.StyledText
        }
        PropertyChanges {
            target: row.lastNameLabel
            text: Theme.highlightText(secondText, _regExpFor(searchString), Theme.highlightColor)
            textFormat: Text.StyledText
        }
        PropertyChanges {
            target: matchDataText
            text: Theme.highlightText(matchText, _regExpFor(searchString), Theme.highlightColor)
            textFormat: Text.StyledText
        }
    }
}
