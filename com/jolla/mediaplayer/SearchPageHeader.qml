import QtQuick 2.0
import Sailfish.Silica 1.0

FocusScope {
    id: scope
    property bool searchAsHeader: false
    property alias title: pageHeader.title
    property alias placeholderText: searchField.placeholderText
    property alias searchText: searchField.text
    property alias coverSource: cover.source
    default property alias _data: bottomCol.data

    implicitHeight: col.height + bottomCol.height

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
                when: !searchField.enabled && (cover.status !== Image.Ready)
                PropertyChanges { target: effect; opacity: 0.0; }
                PropertyChanges { target: header; height: pageHeader.height; }
                PropertyChanges { target: pageHeader; opacity: 1.0; }
                PropertyChanges { target: col; height: pageHeader.height; }
                PropertyChanges { target: searchField; opacity: 0.0; }
            },
            State {
                name: "SEARCH-HEADER"
                when: searchField.enabled && searchAsHeader
                PropertyChanges { target: effect; opacity: 0.0; }
                PropertyChanges { target: header; height: Theme.paddingSmall; }
                PropertyChanges { target: pageHeader; opacity: 0.0; }
                PropertyChanges { target: col; height: pageHeader.height; }
                PropertyChanges { target: searchField; opacity: 1.0; }
            },
            State {
                name: "SEARCH"
                when: searchField.enabled && !searchAsHeader
                PropertyChanges { target: effect; opacity: 0.0; }
                PropertyChanges { target: header; height: pageHeader.height; }
                PropertyChanges { target: pageHeader; opacity: 1.0; }
                PropertyChanges { target: col; height: pageHeader.height + searchField.height; }
                PropertyChanges { target: searchField; opacity: 1.0; }
            },
            State {
                name: "IMAGE"
                when: !searchField.enabled && (cover.status === Image.Ready)
                PropertyChanges { target: pageHeader; opacity: 0.0; }
                PropertyChanges { target: header; height: cover.height + Theme.paddingMedium; }
                PropertyChanges { target: effect; opacity: 1.0; }
                PropertyChanges { target: col; height: cover.height + Theme.paddingMedium; }
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
                        PropertyAnimation { target: header; property: "height"; to: Theme.paddingSmall; }
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
                    PropertyAnimation { target: col; property: "height"; to: cover.height + Theme.paddingMedium; }
                    FadeAnimation { target: effect; property: "opacity"; to: 1.0; }
                }
            },
            Transition {
                from: "IMAGE"
                to: "SEARCH"
                SequentialAnimation {
                    id: toSearch
                    running: false
                    FadeAnimation { target: effect; property: "opacity"; to: 0.0; }
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
            height: pageHeader.visible ? pageHeader.height : cover.height + Theme.paddingMedium

            PageHeader {
                id: pageHeader
                width: parent.width
            }

            Image {
                id: cover
                asynchronous: true
                property real size: parent.width

                width: size
                height: size
                sourceSize.width: size
                sourceSize.height: size
                fillMode: Image.PreserveAspectFit
            }

            OpacityRampEffect {
                id: effect
                slope: 1.0
                offset: 0.0
                direction: OpacityRamp.BottomToTop
                sourceItem: cover
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
