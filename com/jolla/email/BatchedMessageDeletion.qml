/*
 * Copyright (c) 2019 Open Mobile Platform LLC.
 *
 * License: Proprietary
 */

pragma Singleton
import QtQml 2.2

QtObject {
    property var _pendingDeletions: ({})

    function addMessage(messageId) {
        if (messageId) {
            _pendingDeletions[messageId] = true
        }
    }

    function removeMessage(messageId) {
        if (messageId) {
            delete _pendingDeletions[messageId]
        }
    }

    function messageReadyForDeletion(messageId) {
        if (messageId) {
            _pendingDeletions[messageId] = false
        }
    }

    function run(emailAgent) {
        var messageIds = []
        for (var messageId in _pendingDeletions) {
            messageIds.push(messageId)
            if (_pendingDeletions[messageId] === true) {
                // Don't go ahead with the batched deletion until all messages are marked as ready
                // for deletion.
                return
            }
        }

        _pendingDeletions = {}
        if (messageIds.length > 0) {
            emailAgent.deleteMessagesFromVariantList(messageIds)
        }
    }
}
