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

    implicitHeight: col.height + bottomCol.height

    onCoverArtChanged: if (coverArt) coverArt.parent = coverHolder

    function enableSearch() {
        if (searchField.enabled) {
            searchField.forceActiveFocus()
        } else {
            searchField.enabled = true
        }
    }

    Column {
        id: col
        width: parent.width
        state: "HEADER"

        states: [
            State {
                name: "HEADER"
                when: !searchField.enabled && (!coverArt || coverArt.status !== Image.Ready)
                PropertyChanges { target: coverHolder; opacity: 0.0; }
                PropertyChanges { target: header; height: pageHeader.height; }
                PropertyChanges { target: pageHeader; opacity: 1.0; }
                PropertyChanges { target: col; height: pageHeader.height; }
                PropertyChanges { target: searchField; opacity: 0.0; }
            },
            State {
                name: "SEARCH-HEADER"
                when: searchField.enabled && searchAsHeader
                PropertyChanges { target: coverHolder; opacity: 0.0; }
                PropertyChanges { target: header; height: 0; }
                PropertyChanges { target: pageHeader; opacity: 0.0; }
                PropertyChanges { target: col; height: pageHeader.height; }
                PropertyChanges { target: searchField; opacity: 1.0; }
            },
            State {
                name: "SEARCH"
                when: searchField.enabled && !searchAsHeader
                PropertyChanges { target: coverHolder; opacity: 0.0; }
                PropertyChanges { target: header; height: pageHeader.height; }
                PropertyChanges { target: pageHeader; opacity: 1.0; }
                PropertyChanges { target: col; height: pageHeader.height + searchField.height; }
                PropertyChanges { target: searchField; opacity: 1.0; }
            },
            State {
                name: "IMAGE"
                when: !searchField.enabled && (coverArt && coverArt.status === Image.Ready)
                PropertyChanges { target: pageHeader; opacity: 0.0; }
                PropertyChanges { target: header; height: coverArt.height + Theme.paddingMedium; }
                PropertyChanges { target: coverHolder; opacity: 1.0; }
                PropertyChanges { target: col; height: coverArt.height + Theme.paddingMedium; }
                PropertyChanges { target: searchField; opacity: 0.0; }
            }
        ]

        transitions: [
            Transition {
                from: "HEADER"
                to: "SEARCH"
                SequentialAnimation {
                    id: headerToSearch
                    running: false
                    PropertyAnimation { target: col; property: "height"; to: pageHeader.height + searchField.height; }
                    FadeAnimation { target: searchField; property: "opacity"; to: 1.0; }
                }
            },
            Transition {
                from: "SEARCH"
                to: "HEADER"
                SequentialAnimation {
                    id: searchToHeader
                    running: false
                    FadeAnimation { target: searchField; property: "opacity"; to: 0.0; }
                    PropertyAnimation { target: col; property: "height"; to: pageHeader.height; }
                }
            },
            Transition {
                from: "HEADER"
                to: "SEARCH-HEADER"
                SequentialAnimation {
                    id: headerToSearchHeader
                    running: false
                    ParallelAnimation {
                        FadeAnimation { target: pageHeader; property: "opacity"; to: 0.0; }
                        PropertyAnimation { target: header; property: "height"; to: 0; }
                        PropertyAnimation { target: col; property: "height"; to: pageHeader.height; }
                    }
                    FadeAnimation { target: searchField; property: "opacity"; to: 1.0; }
                }
            },
            Transition {
                from: "SEARCH-HEADER"
                to: "HEADER"
                SequentialAnimation {
                    id: searchHeaderToHeader
                    running: false
                    FadeAnimation { target: searchField; property: "opacity"; to: 0.0; }
                    FadeAnimation { target: pageHeader; property: "opacity"; to: 1.0; }
                }
            },
            Transition {
                from: "SEARCH"
                to: "IMAGE"
                SequentialAnimation {
                    id: toCover
                    running: false
                    ParallelAnimation {
                        FadeAnimation { target: pageHeader; property: "opacity"; to: 0.0; }
                        FadeAnimation { target: searchField; property: "opacity"; to: 0.0; }
                    }
                    PropertyAnimation { target: col; property: "height"; to: coverHolder.coverArtSize + Theme.paddingMedium; }
                    FadeAnimation { target: coverHolder; property: "opacity"; to: 1.0; }
                }
            },
            Transition {
                from: "IMAGE"
                to: "SEARCH"
                SequentialAnimation {
                    id: toSearch
                    running: false
                    FadeAnimation { target: coverHolder; property: "opacity"; to: 0.0; }
                    PropertyAnimation { target: col; property: "height"; to: pageHeader.height + searchField.height; }
                    ParallelAnimation {
                        FadeAnimation { target: pageHeader; property: "opacity"; to: 1.0; }
                        FadeAnimation { target: searchField; property: "opacity"; to: 1.0; }
                    }
                }
            }
        ]

        Item {
            id: header

            width: parent.width
            height: pageHeader.visible ? pageHeader.height : coverHolder.coverArtSize + Theme.paddingMedium

            PageHeader {
                id: pageHeader
                width: parent.width
            }

            Item {
                id: coverHolder

                property real coverArtSize: parent.width

                width: coverArtSize
                height: coverArtSize
            }
        }

        SearchField {
            id: searchField
            property bool open: opacity === 1.0

            width: parent.width
            enabled: false
            opacity: 0.0

            // We prefer lowercase
            inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhPreferLowercase | Qt.ImhNoPredictiveText
            EnterKey.iconSource: "image://theme/icon-m-enter-close"
            EnterKey.onClicked: focus = false

            onOpenChanged: if (open) forceActiveFocus()
            onActiveFocusChanged: if (!activeFocus && text == "") enabled = false
        }
    }

    Column {
        id: bottomCol
        width: parent.width
        anchors.top: col.top
        anchors.topMargin: col.height
    }
}
