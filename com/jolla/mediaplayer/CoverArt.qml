/*
 * Copyright (C) 2012-2015 Jolla Ltd.
 *
 * The code in this file is distributed under multiple licenses, and as such,
 * may be used under any one of the following licenses:
 *
 *   - GNU General Public License as published by the Free Software Foundation;
 *     either version 2 of the License (see LICENSE.GPLv2 in the root directory
 *     for full terms), or (at your option) any later version.
 *   - GNU Lesser General Public License as published by the Free Software
 *     Foundation; either version 2.1 of the License (see LICENSE.LGPLv21 in the
 *     root directory for full terms), or (at your option) any later version.
 *   - Alternatively, if you have a commercial license agreement with Jolla Ltd,
 *     you may use the code under the terms of that license instead.
 *
 * You can visit <https://sailfishos.org/legal/> for more information
 */

import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: coverArt

    property alias status: coverImage.status
    property alias source: coverImage.source

    anchors.fill: parent

    Image {
        id: coverImage

        asynchronous: true
        anchors.fill: parent
        sourceSize.width: width
        sourceSize.height: width
        fillMode: Image.PreserveAspectFit
    }

    OpacityRampEffect {
        enabled: coverImage.status === Image.Ready
        offset: 0.0
        slope: 1.0
        direction: isLandscape ? OpacityRamp.TopToBottom : OpacityRamp.BottomToTop
        sourceItem: coverImage
    }
}
