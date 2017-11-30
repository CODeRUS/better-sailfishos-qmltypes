/****************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Valerio Valerio <valerio.valerio@jolla.com>
**
****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    property Item expanderItem
    property Item expansibleItem: children[0]

    width: parent.width
    height: _heightRange.min + _expansionHeight

    property real minimumHeight: _heightRange.min
    property real maximumHeight: _heightRange.max

    property var _heightRange: _getHeightRange()
    property real _compressionRange: (_heightRange.max - _heightRange.min)
    property real _expansionHeight: Math.round(_compressionRange * expanderItem.expansion)
    property real compressionHeight: _compressionRange - _expansionHeight

    // Don't allow a child's compressibility to become false while it is uncompressed
    property var _compressionPrevented

    function _testCompressible() {
        var childNonCompressible = []
        for (var i = 0; i < expansibleItem.children.length; ++i) {
            var child = expansibleItem.children[i]
            childNonCompressible.push(child.visible && !child.compressible)
        }
        _compressionPrevented = childNonCompressible
    }

    Connections {
        target: expanderItem
        onChangingChanged: {
            // Compression is starting - reset the compression prevention flags
            if (expanderItem.changing && (expanderItem.expansion == 1.0)) {
                _testCompressible()
            }
        }
    }

    onCompressionHeightChanged: {
        var compression = compressionHeight
        for (var i = 0; i < expansibleItem.children.length; ++i) {
            var child = expansibleItem.children[i]
            if (child.visible || !child.compressible) {
                if (child.compressible) {
                    // Check that this child wasn't previously prevented from compressing
                    if (_compressionPrevented === undefined || _compressionPrevented[i] === false) {
                        child.compressionHeight = Math.min(compression, child.expandedHeight)
                        compression = compression - child.compressionHeight
                    }
                } else {
                    child.compressionHeight = 0
                }
            }
        }
    }

    function _getHeightRange() {
        var min = 0
        var max = 0

        for (var i = 0; i < expansibleItem.children.length; ++i) {
            var child = expansibleItem.children[i]
            if (child.visible) {
                if (child.expandedHeight) {
                    max += child.expandedHeight
                } else {
                    max += child.height
                }

                if ((child.compressible === undefined) || (child.compressible === false) ||
                    (_compressionPrevented !== undefined && _compressionPrevented[i] === true)) {
                    if (child.expandedHeight) {
                        min += child.expandedHeight
                    } else {
                        min += child.height
                    }
                }
            }
        }

        return { 'min': Math.floor(min), 'max': Math.floor(max) }
    }
}
