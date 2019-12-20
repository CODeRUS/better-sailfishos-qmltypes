import QtQuick 2.0
import Sailfish.Silica 1.0

FocusScope {
    id: scope

    property bool searchAsHeader: isLandscape
    property alias title: pageHeader.title
    property alias placeholderText: searchField.placeholderText
    property alias searchText: searchField.text
    property Item coverArt
    default property alias _data: bottomCol.data
    readonly property int _animationDuration: 200

    implicitHeight: col.height + bottomCol.height

    onCoverArtChanged: if (coverArt) coverArt.parent = coverHolder

    function enableSearch() {
        searchField.active = true
        searchField.forceActiveFocus()
    }

    Column {
        id: col
        width: parent.width
        state: "HEADER"

        states: [
            State {
                name: "HEADER"
                when: !searchField.active && (!coverArt || coverArt.status !== Image.Ready)
                PropertyChanges { target: coverHolder; opacity: 0.0 }
                PropertyChanges { target: pageHeader; opacity: 1.0 }
                PropertyChanges { target: header; height: pageHeader.height }
            },
            State {
                name: "SEARCH-HEADER"
                when: searchField.active && searchAsHeader
                PropertyChanges { target: coverHolder; opacity: 0.0 }
                PropertyChanges { target: pageHeader; opacity: 0.0 }
                PropertyChanges { target: header; height: pageHeader.height }
                PropertyChanges { target: searchField; y: 0 }
            },
            State {
                name: "SEARCH"
                when: searchField.active && !searchAsHeader
                PropertyChanges { target: coverHolder; opacity: 0.0 }
                PropertyChanges { target: pageHeader; opacity: 1.0 }
                PropertyChanges { target: header; height: pageHeader.height + searchField.height }
            },
            State {
                name: "IMAGE"
                when: !searchField.active && (coverArt && coverArt.status === Image.Ready)
                PropertyChanges { target: pageHeader; opacity: 0.0 }
                PropertyChanges { target: header; height: coverArt.height + Theme.paddingMedium }
                PropertyChanges { target: coverHolder; opacity: 1.0 }
            }
        ]

        transitions: [
            Transition {
                from: "SEARCH"
                to: "HEADER"
                PropertyAnimation { duration: scope._animationDuration; target: header; property: "height" }
            },
            Transition {
                from: "HEADER"
                to: "SEARCH-HEADER"
                FadeAnimation { duration: scope._animationDuration; target: pageHeader }
            },
            Transition {
                from: "SEARCH-HEADER"
                to: "HEADER"
                FadeAnimation { duration: scope._animationDuration; target: pageHeader }
            }
        ]

        Item {
            id: header

            width: parent.width
            height: pageHeader.height

            PageHeader {
                id: pageHeader
                width: parent.width
            }

            SearchField {
                id: searchField

                y: pageHeader.height
                width: parent.width
                canHide: text.length === 0
                active: false

                // Only animate in non-cover mode, to prevent height stuttering
                transitionDuration: (coverArt && coverArt.status === Image.Ready) ? 0 : scope._animationDuration

                // We prefer lowercase
                inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhPreferLowercase | Qt.ImhNoPredictiveText

                onHideClicked: active = false

                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: focus = false
            }

            Item {
                id: coverHolder

                property real coverArtSize: parent.width

                width: coverArtSize
                height: coverArtSize
            }
        }
    }

    Column {
        id: bottomCol
        width: parent.width
        anchors.top: col.bottom
    }
}
