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
import Sailfish.Silica.theme 1.0

Image {
    id: albumArt

    property bool highlighted
    property real size: Theme.itemSizeExtraLarge

    height: size
    width: size
    sourceSize.width: size
    sourceSize.height: size

    MusicIcon {
        size: parent.size
        highlighted: parent.highlighted
        visible: albumArt.source == ""
    }
}
