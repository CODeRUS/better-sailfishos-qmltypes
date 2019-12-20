import QtQuick 2.6
import Sailfish.Silica 1.0
import Sailfish.Messages 1.0
import Sailfish.Telephony 1.0
import Sailfish.Contacts 1.0
import org.nemomobile.commhistory 1.0
import org.nemomobile.contacts 1.0
import org.nemomobile.configuration 1.0

InverseMouseArea {
    id: chatInputArea

    property alias text: textField.text
    property alias cursorPosition: textField.cursorPosition
    property alias editorFocus: textField.focus
    property alias empty: textField.empty
    property bool canSend: text.length > 0

    property alias placeholderText: textField.placeholderText
    property string messageTypeName
    property int presenceState
    property string phoneNumberDescription

    property bool needsSimFeatures
    property alias conversationTypeMenu: typeMenu

    //: Generic placeholder for chat input
    //% "Type message"
    readonly property string defaultPlaceholderText: qsTrId("messages-ph-chat_placeholder_generic")

    readonly property int _rightMargin: Theme.horizontalPageMargin + button.width

    signal readyToSend()

    function forceActiveFocus() {
        textField.forceActiveFocus()
    }

    function _prepareToSend() {
        // Reset keyboard state
        if (textField.focus) {
            textField.focus = false
            textField.focus = true
        }
        readyToSend()
    }

    width: parent.width
    height: textField.y + textField.height + ((typeMenu.height + simSelector.height) || Theme.paddingMedium)

    TextArea {
        id: textField

        width: parent.width
        y: Theme.paddingMedium
        focusOutBehavior: FocusBehavior.KeepFocus
        textRightMargin: chatInputArea._rightMargin
        font.pixelSize: Theme.fontSizeSmall
        enabled: chatInputArea.enabled
        placeholderText: defaultPlaceholderText

        VerticalAutoScroll.bottomMargin: Theme.paddingMedium

        property bool empty: text.length === 0 && !inputMethodComposing

        labelComponent: Component {
            Row {
                spacing: Theme.paddingMedium
                height: Math.max(messageType.height, phoneInfoLabel.height)

                Label {
                    id: messageType

                    anchors.verticalCenter: parent.verticalCenter
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeExtraSmallBase
                    text: chatInputArea.messageTypeName
                    visible: !needsSimFeatures
                             || (!simInfoRow.visible && !characterCountLabel.visible)
                }

                CharacterCountLabel {
                    id: characterCountLabel

                    anchors.verticalCenter: parent.verticalCenter
                    visible: active && chatInputArea.text.length > 0
                    active: chatInputArea.needsSimFeatures
                            && characterCountSetting.value
                    messageText: visible ? textField.text : ""
                    font.pixelSize: Theme.fontSizeExtraSmallBase
                }

                ContactPresenceIndicator {
                    id: presence

                    anchors.verticalCenter: parent.verticalCenter
                    visible: presenceState !== Person.PresenceUnknown
                    presenceState: chatInputArea.presenceState
                }

                Label {
                    id: phoneInfoLabel

                    anchors.verticalCenter: parent.verticalCenter
                    visible: text.length > 0
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeExtraSmallBase
                    truncationMode: TruncationMode.Fade
                    text: chatInputArea.phoneNumberDescription

                    width: Math.min(Math.ceil(implicitWidth),
                                    chatInputArea.width - textField.textLeftMargin - chatInputArea._rightMargin
                                    - (messageType.visible ? (messageType.width + parent.spacing) : 0)
                                    - (presence.visible ? (presence.width + parent.spacing) : 0)
                                    - (characterCountLabel.visible ? (characterCountLabel.width
                                                                      + parent.spacing) : 0)
                                    - (simInfoRow.visible ? (simInfoRow.width
                                                             + parent.spacing) : 0)
                                    - Theme.paddingLarge)
                }

                // Bring SIM icon closer to the SIM info label, otherwise it looks awkward
                Row {
                    id: simInfoRow
                    visible: simInfoLabel.text.length > 0

                    HighlightImage {
                        anchors.verticalCenter: parent.verticalCenter
                        color: Theme.highlightColor
                        source: {
                            if (MessageUtils.simManager.activeSim === 0) {
                                return "image://theme/icon-s-sim1"
                            } else if (MessageUtils.simManager.activeSim === 1) {
                                return "image://theme/icon-s-sim2"
                            } else {
                                return ""
                            }
                        }
                    }

                    Label {
                        id: simInfoLabel

                        anchors.verticalCenter: parent.verticalCenter
                        color: Theme.highlightColor
                        font.pixelSize: Theme.fontSizeExtraSmallBase
                        text: chatInputArea.needsSimFeatures
                              && !Telephony.promptForMessageSim
                              && MessageUtils.multipleEnabledSimCards
                              && MessageUtils.simManager.activeSim >= 0
                              ? MessageUtils.simManager.modemSimModel.get(MessageUtils.simManager.activeSim)["operator"]
                              : ""
                    }
                }
            }
        }

        Button {
            id: button

            enabled: chatInputArea.enabled
                     && (typeMenu.enabled || canSend)
            parent: textField
            width: Theme.iconSizeMedium + 2 * Theme.paddingSmall
            height: width
            anchors {
                right: parent.right
                rightMargin: Theme.horizontalPageMargin
                bottom: parent.bottom
                bottomMargin: Theme.paddingSmall
            }
            onClicked: {
                if (textField.empty && typeMenu.enabled) {
                    typeMenu.openMenu(chatInputArea)
                } else {
                    if (!textField.empty) {
                        Qt.inputMethod.commit()
                    }
                    if (chatInputArea.needsSimFeatures && Telephony.promptForMessageSim) {
                        simSelector.openMenu(chatInputArea)
                        return
                    }
                    chatInputArea._prepareToSend()
                }
            }
            onPressAndHold: if (typeMenu.enabled) typeMenu.openMenu(chatInputArea)

            HighlightImage {
                id: image

                source: textField.empty && typeMenu.enabled ? "image://theme/icon-m-change-type"
                                                            : "image://theme/icon-m-send"
                color: !button.enabled ? Theme.secondaryColor
                                       : (button._showPress ? Theme.highlightColor
                                                            : Theme.primaryColor)
                highlighted: parent.down
                anchors.centerIn: parent
                opacity: parent.enabled ? 1.0 : Theme.opacityLow
                Behavior on opacity { FadeAnimator {} }

                Behavior on source {
                    SequentialAnimation {
                        FadeAnimation {
                            target: image
                            to: 0.0
                        }
                        PropertyAction {} // This is where the property assignment really happens
                        FadeAnimation {
                            target: image
                            to: image.parent.enabled ? 1.0 : Theme.opacityLow
                        }
                    }
                }
            }
        }
    }

    onClickedOutside: textField.focus = false

    ConversationTypeMenu {
        id: typeMenu

        enabled: count > 1
        onCloseKeyboard: textField.focus = false
    }

    ContextMenu {
        id: simSelector

        // TODO: remove once Qt.inputMethod.animating has been implemented JB#15726
        property Item lateParentItem
        property bool noKeyboard: lateParentItem && ((isLandscape && pageStack.width === Screen.width) ||
                                                     (!isLandscape && pageStack.height === Screen.height))
        onNoKeyboardChanged: {
            if (noKeyboard) {
                open(lateParentItem)
                lateParentItem = null
            }
        }

        function openMenu(parentItem) {
            // close keyboard if necessary
            if (Qt.inputMethod.visible) {
                textField.focus = false
                lateParentItem = parentItem
            } else {
                open(parentItem)
            }
        }

        SimPicker {
            actionType: Telephony.Message
            onSimSelected: {
                MessageUtils.telepathyAccounts.selectModem(modemPath)
                chatInputArea._prepareToSend()
                simSelector.close()
            }
        }
    }

    ConfigurationValue {
        id: characterCountSetting
        key: "/apps/jolla-messages/show_sms_character_count"
        defaultValue: false
    }
}
