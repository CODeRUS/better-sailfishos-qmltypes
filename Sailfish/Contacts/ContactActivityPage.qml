import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.contacts 1.0

Page {
    id: root

    property alias contact: activityList.contact

    signal startPhoneCall(string number)
    signal startSms(string number)
    signal startInstantMessage(string localUid, string remoteUid)

    ContactActivityList {
        id: activityList

        anchors.fill: parent

        header: Item {
            width: parent ? parent.width : 0
            height: contactLabel.y + contactLabel.height + Theme.paddingMedium

            PageHeader {
                id: header

                //% "Activity"
                title: qsTrId("components_contacts-he-activity")
            }
            Label {
                id: contactLabel

                anchors {
                    top: header.bottom
                    topMargin: -Theme.paddingLarge
                    right: parent.right
                    rightMargin: Theme.horizontalPageMargin
                }
                text: contact.displayLabel
                color: Theme.highlightColor
            }
        }

        model: FormattingProxyModel {
            sourceModel: activityList.contactEventModel
            formattedProperties: [ {
                'role': 'endTimeSection',
                'source': 'endTime',
                'formatter': 'formatDate',
                'parameter': Format.TimepointSectionHistorical
            } ]
        }

        section {
            property: 'endTimeSection'

            delegate: SectionHeader {
                text: section
            }
        }

        onStartPhoneCall: root.startPhoneCall(number)
        onStartSms: root.startSms(number)
        onStartInstantMessage: root.startInstantMessage(localUid, remoteUid)

        VerticalScrollDecorator {}

        ViewPlaceholder {
            id: placeholder

            enabled: activityList.count === 0
            //% "No communications activity"
            text: qsTrId("components_contacts-la-no_activity")
        }
    }
}
