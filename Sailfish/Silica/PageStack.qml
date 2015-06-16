/****************************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Joona Petrell <joona.petrell@jollamobile.com>
** All rights reserved.
** 
** This file is part of Sailfish Silica UI component package.
**
** You may use this file under the terms of BSD license as follows:
**
** Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are met:
**     * Redistributions of source code must retain the above copyright
**       notice, this list of conditions and the following disclaimer.
**     * Redistributions in binary form must reproduce the above copyright
**       notice, this list of conditions and the following disclaimer in the
**       documentation and/or other materials provided with the distribution.
**     * Neither the name of the Jolla Ltd nor the
**       names of its contributors may be used to endorse or promote products
**       derived from this software without specific prior written permission.
** 
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
** ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
** WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
** DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
** ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
** (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
** LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
** ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
** SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**
****************************************************************************************/

/****************************************************************************
**
** Copyright (C) 2011 Nokia Corporation and/or its subsidiary(-ies).
** All rights reserved.
** Contact: Nokia Corporation (qt-info@nokia.com)
**
** This file is part of the Qt Components project.
**
** $QT_BEGIN_LICENSE:BSD$
** You may use this file under the terms of the BSD license as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of Nokia Corporation and its Subsidiary(-ies) nor
**     the names of its contributors may be used to endorse or promote
**     products derived from this software without specific prior written
**     permission.
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
** $QT_END_LICENSE$
**
****************************************************************************/

// The PageStack item defines a container for pages and a stack-based
// navigation model. Pages can be defined as QML items or components.

import QtQuick 2.0
import Sailfish.Silica 1.0
import "PageStack.js" as PageStack
import "private"

PageStackBase {
    id: root

    width: parent.width
    height: parent.height

    currentPage: _currentContainer ? _currentContainer.page : null
    backNavigation: currentPage !== null && currentPage.backNavigation && depth > 1
    forwardNavigation: currentPage !== null && currentPage.forwardNavigation &&
                       (depth > 1 || _currentContainer.attachedContainer !== null ||
                        (_pendingContainer !== null && currentPage._forwardDestinationAction !== PageStackAction.Pop))

    // Page stack depth
    property int depth

    // Indicates whether there is an ongoing page transition.
    property bool busy: _ongoingTransitionCount > 0

    property bool acceptAnimationRunning: _pageStackIndicator == null ? false : _pageStackIndicator.animatingPosition

    property int _currentOrientation: currentPage ? currentPage.orientation : Orientation.Portrait
    property real _currentWidth: currentPage ? currentPage.width : 0

    // The number of ongoing transitions.
    property int _ongoingTransitionCount

    // Duration of transition animation (in ms)
    property int _transitionDuration: 500

    property Item _pageStackIndicator
    property Item _pendingContainer
    property Item _previousContainer
    property real _flickThreshold: Theme.itemSizeMedium

    // Any currently active PullDownMenu in the page stack
    property Item _activePullDownMenu

    // Inclusive of the input method panel, if open:
    property real _effectiveWidth: parent.width
    property real _effectiveHeight: parent.height

    property bool _dialogAtTop: _currentContainer !== null && _currentContainer.containsDialog

    property bool _preventForwardNavigation: currentPage !== null && currentPage.forwardNavigation && (currentPage.canNavigateForward === false)

    // Temporary provision for backward compatibility:
    function pushExtra(page, properties) { return pushAttached(page, properties) }
    function _navigateBack(operationType) { return navigateBack(operationType) }
    function _navigateForward(operationType) { return navigateForward(operationType) }

    // Pushes a page on the stack.
    // The page can be defined as a component, item or string.
    // If an item is used then the page will get visually re-parented.
    // If a string is used then it is interpreted as a url that is used to load a page component.
    //
    // The page can also be given as an array of pages. In this case all those pages will be pushed
    // onto the stack. The items in the stack can be components, items or strings just like for single
    // pages. Additionally an object can be used, which specifies a page and an optional properties
    // property. This can be used to push multiple pages while still giving each of them properties.
    // When an array is used the transition animation will only be to the last page.
    //
    // The properties argument is optional and allows defining a map of properties to set on the page.
    // If the operationType argument is PageStackAction.Immediate then no transition animation is performed.
    // Returns the page instance.
    function _push(page, properties, operationType) {
        return PageStack.push(page, properties, false, _normalizeOperationType(operationType))
    }

    // Pops a page off the stack.
    // If page is specified then the stack is unwound to that page; null to unwind the to first page.
    // If the operationType argument is PageStackAction.Immediate then no transition animation is performed.
    // Returns the page instance that was popped off the stack.
    function pop(page, operationType) {
        return PageStack.pop(page, _normalizeOperationType(operationType))
    }

    // Replaces a page on the stack.
    // See push() for details.
    function _replace(page, properties, operationType) {
        return PageStack.push(page, properties, true, _normalizeOperationType(operationType))
    }

    // Replaces all pages above existingPage with page
    function _replaceAbove(existingPage, page, properties, operationType) {
        if (existingPage === undefined) {
            throw new Error("replaceAbove() called with an undefined existingPage specified")
        }
        return PageStack.push(page, properties, true, _normalizeOperationType(operationType), existingPage)
    }

    // Clears the page stack.
    function clear() {
        return PageStack.clear()
    }

    // Push a page onto the stack which is attached to the current stack top, without moving to it
    function _pushAttached(page, properties) {
        return PageStack.pushAttached(page, properties)
    }

    // Pop an attached page from the top of the stack
    function popAttached(page, operationType) {
        return PageStack.popAttached(page, _normalizeOperationType(operationType))
    }

    // Returns the previous page or a null if the supplied page is the first one.
    function previousPage(fromPage) {
        var fromContainer
        if (fromPage) {
            fromContainer = _findContainer(function (page) { return (page === fromPage) })
            if (!fromContainer) {
                throw new Error("Cannot find previousPage for argument not present in stack: " + fromPage)
            }
        } else {
            fromContainer = _currentContainer
        }

        var container = PageStack.containerBelow(fromContainer)
        return container ? container.page : null
    }

    // Returns the next page or null if the supplied page is the stack top
    function nextPage(fromPage) {
        var fromContainer
        if (fromPage) {
            fromContainer = _findContainer(function (page) { return (page === fromPage) })
            if (!fromContainer) {
                throw new Error("Cannot find nextPage for argument not present in stack: " + fromPage)
            }
        } else {
            fromContainer = _currentContainer
        }

        var container = PageStack.containerAbove(fromContainer)
        if (container) {
            return container.page
        } else if (fromContainer.attachedContainer) {
            return fromContainer.attachedContainer.page
        } else {
            return null
        }
    }

    // Iterates through all pages (top to bottom) and invokes the specified function.
    // If the specified function returns true the search stops and the find function
    // returns the page that the iteration stopped at. If the search doesn't result
    // in any page being found then null is returned.
    function find(func) {
        var container = PageStack.find(func)
        return container ? container.page : null
    }

    function _findContainer(func) {
        return PageStack.find(func)
    }

    function _containerBelow(container) {
        return PageStack.containerBelow(container)
    }

    // TODO: navigate back/forward fail when operationType is PageStackAction.Immediate

    // Navigate back one page by popping the page stack.
    function navigateBack(operationType) {
        if (!backNavigation) {
            return null
        }

        snapBackAnimation.clearTarget(false)

        operationType = _normalizeOperationType(operationType)
        if (_currentContainer.attached) {
            return PageStack.exitAttached(operationType)
        }

        if (currentPage !== null) {
            currentPage._navigation = PageNavigation.Back
        }
        return pop(undefined, operationType)
    }

    // Navigate forward one page by popping the page stack.
    function navigateForward(operationType) {
        if (!forwardNavigation) {
            return null
        }

        if (_preventForwardNavigation) {
            // Flash briefly to indicate that forward navigation is not possible
            flash.flashPage()

            // Return the page to correct position, if it has been dragged out of position
            snapBackAnimation.duration = _calculateDuration(0, _currentContainer.lateralOffset)
            snapBackAnimation.restart()
            return null
        }

        snapBackAnimation.clearTarget(false)

        operationType = _normalizeOperationType(operationType)
        if (_currentContainer.attachedContainer) {
            return PageStack.enterAttached(_currentContainer.attachedContainer, operationType)
        }

        if (currentPage !== null) {
            currentPage._navigationPending = PageNavigation.Forward
            currentPage._navigation = PageNavigation.Forward
        }
        if (_pendingContainer !== null) {
            return PageStack.pushPending(operationType)
        }
        return pop(undefined, operationType)
    }

    function openDialog(dialog, properties, operationType) {
        console.log('Warning: openDialog is deprecated - please use pageStack.push() instead.')
        return push(dialog, properties, operationType)
    }

    function replaceWithDialog(dialog, properties, operationType) {
        console.log('Warning: replaceWithDialog is deprecated - please use pageStack.replace() instead.')
        return replace(dialog, properties, operationType)
    }

    // Complete active transition immediately
    function completeAnimation() {
        _reset()

        if (busy) {
            if (slideAnimation.target) {
                slideAnimation.complete()
                slideAnimation.target.resetPending(true)
            }
            if (fadeAnimation.target) {
                fadeAnimation.complete()
                fadeAnimation.target.resetPending(true)
            }
        }
    }

    function _normalizeOperationType(input) {
        if (input === undefined) {
            input = PageStackAction.Animated
        } else if (typeof(input) === 'boolean') {
            // Temporary support to provide backward compatibility for 'immediate' arguments:
            input = input ? PageStackAction.Immediate : PageStackAction.Animated
        } else if (typeof(input) !== 'number') {
            console.log('Warning: invalid operationType: ' + input + ' ' + typeof(input))
        }
        return input
    }

    // Sets the page status.
    function _setPageStatus(page, status) {
        if (page !== null && page.status !== undefined) {
            if ((page._navigation !== PageNavigation.None) &&
                (page.status !== status) &&
                (status === PageStatus.Active || status === PageStatus.Activating)) {
                // If we have previously navigated away from this page, set back to None
                page._navigation = PageNavigation.None
                page._navigationPending = PageNavigation.None
            }

            if (status === PageStatus.Active && page.status === PageStatus.Inactive) {
                page.status = PageStatus.Activating
            } else if (status === PageStatus.Inactive && page.status === PageStatus.Active) {
                page.status = PageStatus.Deactivating
            }
            page.status = status
        }
    }
    function _calculateDuration(destination, location) {
        var distance = (destination - location)
        if (distance == 0) {
            return 1
        }
        return _transitionDuration * Math.abs(distance) / _currentWidth
    }

    function _reset() {
        if (snapBackAnimation.running) {
            snapBackAnimation.complete()
        }
        snapBackAnimation.clearTarget(true)
        dragBinding.clearTarget()
    }

    function _pushTransition(container, oldContainer, replace, operationType) {
        var rv = undefined

        _reset()
        container.show()

        if (!oldContainer) {
            operationType = PageStackAction.Immediate
        } else {
            oldContainer.expired = replace
        }

        if (operationType == PageStackAction.Immediate) {
            // The caller should apply this state change after completing any internal state modification
            rv = (function() {
                container.enterImmediate()
                if (oldContainer) {
                    oldContainer.exitImmediate()
                }
            })
        } else {
            container.pushEnter(oldContainer)
            if (oldContainer) {
                oldContainer.pushExit(container)
            }
        }

        return rv
    }

    function _popTransition(container, oldContainer, expire, operationType) {
        var rv = undefined

        _reset()
        container.show()

        if (!oldContainer) {
            operationType = PageStackAction.Immediate
        } else {
            oldContainer.expired = expire
        }

        if (operationType == PageStackAction.Immediate) {
            // The caller should apply this state change after completing any internal state modification
            rv = (function() {
                container.enterImmediate()
                if (oldContainer) {
                    oldContainer.exitImmediate()
                }
            })
        } else {
            container.popEnter(oldContainer)
            if (oldContainer) {
                oldContainer.popExit(container)
            }
        }

        return rv
    }

    function _indicatorMaxOpacity() {
        if (!root.currentPage || root.currentPage.showNavigationIndicator == false)
            return 0.0
        // When a pull down menu is active (and intersects the indicator), reduce the opacity of the indicator 
        if (_activePullDownMenu && _pageStackIndicator && _pageStackIndicator.enabled) {
            var menuPosition = _activePullDownMenu.mapToItem(root.currentPage, 0, _activePullDownMenu.height)
            var indicatorExtent = _pageStackIndicator.mapToItem(root.currentPage, _pageStackIndicator.width, _pageStackIndicator.height)
            return (menuPosition.x < indicatorExtent.x) && (menuPosition.y < indicatorExtent.y) ? 0.0 : 1.0
        }
        return 1.0
    }

    property int dragDirection: PageNavigation.None
    onDragDirectionChanged: {
        if (currentPage && (currentPage._navigation == PageNavigation.None)) {
            currentPage._navigationPending = dragDirection
        }
    }

    property bool dragInvalidated
    onDragInvalidatedChanged: {
        if (dragInvalidated) {
            snapBackAnimation.clearTarget(true)
            updatePeekContainer()
        }
    }

    Binding {
        target: root
        property: 'dragInvalidated'
        when: dragDirection === PageNavigation.Forward
        value: _backFlickDifference > 0
    }
    Binding {
        target: root
        property: 'dragInvalidated'
        when: dragDirection === PageNavigation.Back
        value: _forwardFlickDifference > 0
    }

    function updatePeekContainer() {
        var peekContainer
        var push = true
        if (_forwardFlickDifference > 0) {
            dragDirection = PageNavigation.Forward
            if (_currentContainer.attachedContainer) {
                peekContainer = _currentContainer.attachedContainer
                // This is always push
            } else if (_pendingContainer) {
                peekContainer = _pendingContainer
                push = peekContainer.pageStackIndex === -1 || peekContainer.pageStackIndex > _currentContainer.pageStackIndex
            }
        } else {
            dragDirection = PageNavigation.Back
            push = false
        }

        flash.opacity = 0.0
        dragInvalidated = false

        if (!peekContainer) {
            peekContainer = PageStack.containerBelow(_currentContainer)
            push = false
        }

        if (peekContainer) {
            snapBackAnimation.setTarget(_currentContainer, peekContainer)

            // Is the peek container able to slide in when the current container is dragged?
            peekContainer.testSlideTransition(push)
        }
    }

    // Should be private, but name can't start with underscore:
    property bool dragInProgress: (_backFlickDifference > 0) || (_forwardFlickDifference > 0)
    onDragInProgressChanged: {
        if (dragInProgress) {
            updatePeekContainer()
        }
    }

    function _createPageIndicator() {
        if (!_pageStackIndicator) {
            var pageStackIndicatorComponent = Qt.createComponent("private/PageStackIndicator.qml")
            if (pageStackIndicatorComponent.status === Component.Ready) {
                _pageStackIndicator = pageStackIndicatorComponent.createObject(__silica_applicationwindow_instance.indicatorParentItem)
            } else {
                console.log(pageStackIndicatorComponent.errorString())
                return
            }
        }
    }
    onBackNavigationChanged: {
        if (backNavigation) {
            _createPageIndicator()
        }
    }    
    onForwardNavigationChanged: {
        if (forwardNavigation) {
            _createPageIndicator()
        }
    }

    onPressed: {
        if (!busy && _currentContainer && _currentContainer.page) {
            if (snapBackAnimation.running) {
                // stop existing snap back animation
                snapBackAnimation.stop()
                snapBackAnimation.clearTarget(false)
            }

            // start dragging
            dragBinding.setTarget(_currentContainer)
        }
    }
    onReleased: {
        var pageChanged = dragBinding.targetItem !== _currentContainer

        dragBinding.clearTarget()

        if (!pageChanged) {
            // activate navigation if the page has been dragged far enough
            if (_forwardFlickDifference > _flickThreshold) {
                navigateForward(PageStackAction.Animated)
            } else if (_backFlickDifference > _flickThreshold) {
                navigateBack(PageStackAction.Animated)
            } else {
                // otherwise slide the page back to normal position
                if (_currentContainer == snapBackAnimation.target) {
                    snapBackAnimation.duration = _calculateDuration(0, _currentContainer.lateralOffset)
                    snapBackAnimation.restart()
                }
            }
        }

        // Remove the flash if present
        flash.opacity = 0.0
        dragDirection = PageNavigation.None
    }
    onCanceled: {
        dragBinding.clearTarget()

        // slide the page back to normal position
        if (_currentContainer == snapBackAnimation.target) {
            snapBackAnimation.duration = _calculateDuration(0, _currentContainer.lateralOffset)
            snapBackAnimation.restart()
        }

        // Remove the flash if present
        flash.opacity = 0.0
        dragDirection = PageNavigation.None
    }

    Rectangle {
        id: flash
        anchors.fill: parent
        color: Theme.primaryColor
        opacity: 0
        visible: opacity > 0

        function flashPage() {
            opacity = 0.3
            opacity = 0.0
        }

        Behavior on opacity {
            enabled: flash.visible
            FadeAnimation { duration: 400 }
        }
    }
    Binding {
        target: flash
        property: "opacity"
        when: _forwardFlickDifference > 0 && _preventForwardNavigation
        value: 0.3
    }
    Binding {
        id: dragBinding

        property Item targetItem
        property real offset

        target: targetItem
        when: root.pressed
        property: "lateralOffset"

        // If we can't navigate forward, only allow the page to be dragged slightly
        value: offset + root._backFlickDifference - Math.min(root._forwardFlickDifference, (_preventForwardNavigation ? _flickThreshold / 4 : root.width))

        function setTarget(container) {
            offset = container.lateralOffset
            targetItem = container
        }

        function clearTarget() {
            targetItem = null
        }
    }
    Binding {
        target: _pageStackIndicator
        property: "maxOpacity"
        value: _indicatorMaxOpacity()
    }
    SequentialAnimation {
        id: fadeAnimation

        property Item target

        function setTarget(container) {
            target = container
            fadeIn.target = container
            fadeOut.target = container.transitionPartner
        }

        function clearTarget(container) {
            if (target === container) {
                target = null
                fadeIn.target = null
                fadeOut.target = null
            }
        }

        PropertyAnimation {
            id: fadeOut
            property: "opacity"
            to: 0.0
            easing.type: Easing.InQuad
            duration: _transitionDuration / 2
        }
        PropertyAnimation {
            id: fadeIn
            property: "opacity"
            to: 1.0
            easing.type: Easing.OutQuad
            duration: _transitionDuration / 2
        }
    }
    PropertyAnimation {
        id: slideAnimation
        property: "lateralOffset"
        to: 0.0
        easing.type: (duration == _transitionDuration ? Easing.InOutQuad : Easing.OutQuad)

        function setTarget(container) {
            target = container
        }

        function clearTarget(container) {
            if (target === container) {
                target = null
            }
        }
    }
    PropertyAnimation {
        id: snapBackAnimation
        to: 0.0
        property: "lateralOffset"
        easing.type: Easing.InOutQuad
        onStopped: clearTarget(true)

        function setTarget(container, partner) {
            if (container.transitionPartner && container.transitionPartner != partner) {
                container.transitionPartner.transitionPartner = null
            }
            container.transitionPartner = partner
            partner.transitionPartner = container
            target = container

            // Ensure the page container we will peek at is visible
            partner.show()
        }

        function clearTarget(removeLinks) {
            // hide the page container below after sliding back the current page
            if (target) {
                if (target.transitionPartner && removeLinks) {
                    target.transitionPartner.transitionPartner = null
                    target.transitionPartner.hide()
                    target.transitionPartner.fixLateralPosition = false
                    target.transitionPartner = null
                }
                if (target.lateralOffset === 0.0) {
                    target.opacity = 1.0
                }
                target = null
            }
        }
    }
    Binding {
        // Block touch input when the page stack is activating a page, or the page is re-orienting
        when: touchBlockTimer.running || (currentPage && currentPage.orientationTransitionRunning)
        target: __silica_applicationwindow_instance._touchBlockerItem
        property: "enabled"
        value: true
    }
    Timer {
        // Use a timer to re-enable touch input during animation, or the slow tail-off
        // of the animation will cause some input to be attempted too early
        id: touchBlockTimer
    }
    PageEdgeTransition {
        stack: root
    }

    Component {
        id: containerComponent

        FocusScope {
            id: container

            property Item page
            property Item owner
            property int pageStackIndex: -1
            property Item transitionPartner
            property QtObject animation
            property bool expired
            property bool animationRunning: animation ? animation.running : false
            property bool justCreated: true
            property bool attached
            property Item attachedContainer
            property bool containsDialog: page !== null && page.hasOwnProperty('__silica_dialog')
            property bool fixLateralPosition
            property int __silica_pagestack_container

            property real lateralOffset

            x: fixLateralPosition ? 0 : (_currentOrientation == Orientation.Portrait ? lateralOffset : (_currentOrientation == Orientation.PortraitInverted ? -lateralOffset : 0))
            y: fixLateralPosition ? 0 : (_currentOrientation == Orientation.Landscape ? lateralOffset : (_currentOrientation == Orientation.LandscapeInverted ? -lateralOffset : 0))

            width: parent ? parent.width : 0
            height: parent ? parent.height : 0

            focus: page !== null && page.status === PageStatus.Active

            // Return to the event loop on animation end, because the page status change handler might
            // start another animation, which would then be detected as a binding loop
            onAnimationRunningChanged: if (!animationRunning) animationCompletedTimer.restart()

            function show() {
                visible = true
                page.visible = true
            }
            function hide() {
                visible = false
                page.visible = false
            }
            function removeAnimation() {
                if (animation) {
                    animation.clearTarget(container)
                    animation = null
                }
            }
            function resetPending(noWarnings) {
                // Ensure that we don't have any actions pending
                if (delayedTransitionTimer.running) {
                    if (!noWarnings) {
                        console.log('WARNING - preventing animation on reset!')
                    }
                    delayedTransitionTimer.stop()
                    animation.restart()
                    animation.complete()
                }
                if (animationCompletedTimer.running) {
                    if (!noWarnings) {
                        console.log('WARNING - previous animation not yet completed!')
                    }
                    animationCompletedTimer.stop()
                    transitionEnded()
                }
            }
            function enterImmediate() {
                resetPending()
                opacity = 1.0
                lateralOffset = 0
                page.pageContainer = root
                _setPageStatus(page, PageStatus.Active)
            }
            function exitImmediate() {
                resetPending()
                hide()
                _setPageStatus(page, PageStatus.Inactive)
                if (expired) {
                    cleanup()
                }
            }
            function testSlideTransition(push) {
                if (!transitionPartner) {
                    return false
                }
                // Use a fade transition we're going to a page that doesn't allow backstepping
                if ((push && !page.backNavigation) || (!push && !transitionPartner.page.backNavigation)) {
                    return false
                }

                // Use fade transition if orientation will change
                var nextOrientation = __silica_applicationwindow_instance._selectOrientation(page.allowedOrientations)
                if (transitionPartner.page.orientation !== nextOrientation) {
                    if (dragInProgress) {
                        // A drag has been used - continue to use slide transition, but don't move with it
                        fixLateralPosition = true
                    } else {
                        return false
                    }
                }
                return true
            }
            function pushEnter(partner) {
                resetPending()
                transitionPartner = partner

                if (testSlideTransition(true)) {
                    // If the slide is to move the dragged partner out, allow for their width (which may not match ours)
                    lateralOffset = transitionPartner.lateralOffset + (fixLateralPosition ? transitionPartner.width : _currentWidth)
                    slideAnimation.duration = _calculateDuration(0, lateralOffset)
                    animation = slideAnimation
                } else {
                    lateralOffset = 0
                    opacity = 0.0
                    animation = fadeAnimation
                }

                page.pageContainer = root
                transitionStarted()
            }
            function popEnter(partner) {
                resetPending()
                transitionPartner = partner

                if (testSlideTransition(false)) {
                    if (transitionPartner.page._navigation == PageNavigation.Forward) {
                        lateralOffset = transitionPartner.lateralOffset + _currentWidth
                    } else {
                        lateralOffset = transitionPartner.lateralOffset - _currentWidth
                    }
                    slideAnimation.duration = _calculateDuration(0, lateralOffset)
                    animation = slideAnimation
                } else {
                    lateralOffset = 0
                    opacity = 0.0
                    animation = fadeAnimation
                }

                page.pageContainer = root
                transitionStarted()
            }
            function pushExit(partner) {
                resetPending()
                transitionPartner = partner
                _setPageStatus(page, PageStatus.Deactivating)
            }
            function popExit(partner) {
                resetPending()
                transitionPartner = partner
                _setPageStatus(page, PageStatus.Deactivating)
            }
            function transitionStarted() {
                // Animation runs on the activating page
                _setPageStatus(page, PageStatus.Activating)

                if (animation) {
                    _ongoingTransitionCount++
                    animation.setTarget(container)

                    // Is this helpful?
                    if (justCreated) {
                        justCreated = false
                        delayedTransitionTimer.restart()
                    } else {
                        animation.restart()
                    }

                    // Block touch input until the animation is nearly finished
                    touchBlockTimer.interval = Math.max(animation.duration - 50, 1)
                    touchBlockTimer.restart()
                }
            }
            function transitionEnded() {
                // Ensure that touch input is no longer blocked, even if the timer hasn't expired
                touchBlockTimer.stop()

                if (transitionPartner) {
                    // Clean up the transition partner
                    transitionPartner.transitionPartner = null
                    transitionPartner.transitionEnded()
                    transitionPartner = null
                }

                PageStack.transitionEnded(container)

                if (animation) {
                    removeAnimation()

                    if (_ongoingTransitionCount === 1) {
                        PageStack.allTransitionsEnded()
                    }
                    _ongoingTransitionCount--
                }

                fixLateralPosition = false

                // if the page hasn't been manually destroyed, visually reparent it back.
                if (page !== null) {
                    if (page.status === PageStatus.Activating) {
                        _setPageStatus(page, PageStatus.Active)

                        // Ensure we are fully opaque
                        opacity = 1.0
                    } else if (page.status === PageStatus.Deactivating){
                        _setPageStatus(page, PageStatus.Inactive)
                        hide()
                        if (expired) {
                            cleanup()
                        } else {
                            lateralOffset = 0
                        }
                    }
                }
            }
            function cleanup() {
                if (attachedContainer !== null && attachedContainer.pageStackIndex == -1) {
                    attachedContainer.cleanup()
                }
                // if the page hasn't been manually destroyed, visually reparent it back.
                if (page !== null) {
                    if (page.status === PageStatus.Active) {
                        _setPageStatus(page, PageStatus.Inactive)
                    }
                    if (owner != container) {
                        // container is not the owner of the page - re-parent back to original owner
                        page.visible = false
                        page.parent = owner
                    }
                    page.pageContainer = null
                }
                container.destroy()
            }
            function isPositioned() {
                // If this container is being positioned by an animation or user action
                return (container === dragBinding.targetItem) || (container === slideAnimation.target) || (container === snapBackAnimation.target)
            }

            Binding {
                // When the container is top of the stack, or involved in a transition with the top of stack
                target: container.page
                property: '_exposed'
                value: (_currentContainer === container) || (_currentContainer !== null && (_currentContainer === container.transitionPartner))
            }
            Binding {
                // When the container is active, but not the top of the stack
                target: container.page
                property: '_belowTop'
                value: (_currentContainer === container) && (container.attachedContainer !== null)
            }
            Binding {
                // When the container is involved in a lateral transition with an animated container
                target: container
                property: "lateralOffset"
                when: transitionPartner && transitionPartner.isPositioned()
                value: !transitionPartner
                       ? container.lateralOffset
                       : (transitionPartner.lateralOffset === 0
                            ? (container.attached ? _currentWidth : -_currentWidth)
                            : transitionPartner.lateralOffset + (transitionPartner.lateralOffset < 0 ? _currentWidth : -_currentWidth))
            }
            Binding {
                // When the container is involved in a lateral transition
                target: container
                property: "opacity"
                when: container.lateralOffset !== 0
                value: transitionPartner
                       ? (!fixLateralPosition && (page.status === PageStatus.Activating
                         || (_currentContainer == transitionPartner && page.status !== PageStatus.Deactivating))
                          ? 1.0
                          : 1.0 - Math.abs(container.lateralOffset) / (fixLateralPosition ? transitionPartner.width : _currentWidth))
                       : 0
            }
            Timer {
                id: animationCompletedTimer
                interval: 1
                onTriggered: container.transitionEnded()
            }
            Timer {
                id: delayedTransitionTimer
                interval: 20
                onTriggered: container.animation.restart()
            }
        }
    }

    function _callUrlMethod(name, pos, originalArguments)
    {
        // Convert the original arguments to an array.
        var args = Array.prototype.slice.call(originalArguments, 0);
        var func = this[name];

        // If the argument is a just 'Something.qml' we need to resolve
        // the relative path to it. We do that by looking at the call
        // stack.
        if (typeof args[pos] === 'string' && args[pos].search(/\.qml/i) > 0 && args[pos].search(":") < 0 && args[pos].charAt(0) !== '/') {
            var originCallFrame = new Error().stack.split("\n")[2]; // (3rd stack frame)...
            // extracts path from: functionName@(url:///path/to/something).qml:lineNumber" (and .js)
            var res = originCallFrame.match(/@(.*)\/.+:-?\d+/);
            if (!res || res.length < 2)
                throw "Unable to load page: '" + args[pos] + "'";
            res = res[1];
            args[pos] = res + "/" + args[pos];
        }

        // Call the named function with the potentially modified arguments array.
        return func.apply(this, args);
    }
    function push() {
        return _callUrlMethod("_push", 0, arguments);
    }
    function replace() {
        return _callUrlMethod("_replace", 0, arguments);
    }
    function replaceAbove() {
        return _callUrlMethod("_replaceAbove", 1, arguments);
    }
    function pushAttached() {
        return _callUrlMethod("_pushAttached", 0, arguments);
    }
}
